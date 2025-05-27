using System.Reflection;
using System.Text;
using API.Middlewares;
using Application.Interfaces;
using Application.Interfaces.Services;
using Application.Mappings;
using Application.Services;
using Application.Validators;
using FluentValidation;
using FluentValidation.AspNetCore;
using Infrastructure.Persistence;
using Infrastructure.Persistence.Contexts;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// 1. DbContext'i Ekleme
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"), // appsettings.json'dan bağlantı string'ini al
        b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName))); // Migration'ların hangi assembly'de olduğunu belirt

// 2. Unit of Work ve Repository'leri Kaydetme
// Unit of Work'ü Scoped olarak kaydetmek genellikle en iyisidir (HTTP isteği başına bir instance).
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
// Repository'ler UnitOfWork üzerinden erişildiği için ayrıca kaydedilmesine gerek yok.

// 3. Application Servislerini Kaydetme
// Servislerin lifetime'ı (Scoped, Transient, Singleton) ihtiyaca göre belirlenir.
// Genellikle Scoped veya Transient uygundur.
builder.Services.AddScoped<IAccountService, AccountService>();
builder.Services.AddScoped<ITransactionService, TransactionService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IBudgetService, BudgetService>();
builder.Services.AddScoped<IDebtService, DebtService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IPdfGeneratorService, Infrastructure.Services.PdfGeneratorService>();
builder.Services.AddScoped<IExcelGeneratorService, Infrastructure.Services.ExcelGeneratorService>();

// 4. AutoMapper'ı Kaydetme
// Application katmanındaki Assembly'yi tarayarak Profilleri bulur.
// GeneralProfile'in bulunduğu Assembly'yi belirtmek daha güvenli olabilir.
builder.Services.AddAutoMapper(Assembly.GetAssembly(typeof(GeneralProfile)));

// 5. FluentValidation'ı Kaydetme
// Application katmanındaki Assembly'yi tarayarak Validator'ları bulur.
// RegisterDtoValidator'ın bulunduğu Assembly'yi belirtmek daha güvenli olabilir.
builder.Services.AddValidatorsFromAssembly(
    Assembly.GetAssembly(typeof(RegisterDtoValidator))); // Validator'ların lifetime'ını Scoped yapalım
// ASP.NET Core MVC/API pipeline'ına entegrasyon (isteğe bağlı, otomatik validasyon için)
builder.Services.AddControllers()
    .AddFluentValidation(fv =>
    {
        fv.ImplicitlyValidateChildProperties = true; // İç içe DTO'ları da valide et
        fv.ImplicitlyValidateRootCollectionElements = true; // Koleksiyonları da valide et
        // Validator'ların Assembly'sini tekrar belirtmeye gerek yok (yukarıda AddValidatorsFromAssembly ile yapıldı)
        // fv.RegisterValidatorsFromAssemblyContaining<RegisterDtoValidator>();
    });

// 6. JWT Authentication Ayarları
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKeyString = jwtSettings["Secret"];
if (string.IsNullOrEmpty(secretKeyString))
{
    throw new InvalidOperationException("JWT Secret not configured in appsettings.json");
}

var secretKey = Encoding.ASCII.GetBytes(secretKeyString);

builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme; // Bunu da eklemek iyi olabilir
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = builder.Environment.IsProduction(); // Production'da HTTPS zorunlu olsun
        options.SaveToken = true; // Token'ı HttpContext içinde sakla
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(secretKey),
            ValidateIssuer = true, // Issuer'ı doğrula
            ValidIssuer = jwtSettings["Issuer"],
            ValidateAudience = true, // Audience'ı doğrula
            ValidAudience = jwtSettings["Audience"],
            ValidateLifetime = true, // Token ömrünü doğrula
            ClockSkew = TimeSpan.Zero // Token süresi dolduğunda hemen geçersiz sayılsın
        };
    });

// Authorization policy'leri burada tanımlanabilir (gerekirse).
// builder.Services.AddAuthorization(options => { ... });

// 7. API Controller'larını Ekleme
// builder.Services.AddControllers(); // AddFluentValidation ile zaten eklendi.

// 8. Swagger/OpenAPI Entegrasyonu (API Dokümantasyonu ve Test için)
builder.Services.AddEndpointsApiExplorer(); // API Explorer'ı etkinleştir
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Akıllı Finans Uygulaması API", Version = "v1" });

    // Swagger UI'da JWT Bearer token girişi için ayar
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description =
            "JWT Authorization header using the Bearer scheme ('Bearer' keyword followed by space and token). Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http, // Http tipini kullanıyoruz
        Scheme = "bearer", // Scheme küçük harfle 'bearer' olmalı
        BearerFormat = "JWT"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer" // Yukarıdaki AddSecurityDefinition'daki Id ile eşleşmeli
                },
                Scheme = "oauth2", // Scheme eklenmeli
                Name = "Bearer", // Name eklenmeli
                In = ParameterLocation.Header, // In eklenmeli
            },
            new List<string>() // Boş liste scopes belirtir (gerekirse roller eklenebilir)
        }
    });

    // XML yorumlarını Swagger'a dahil etmek için (csproj dosyasında GenerateDocumentationFile true olmalı)
    // API projesinin Assembly'sini kullanmak daha doğru olur.
    var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFilename);
    if (File.Exists(xmlPath)) // Dosya varsa dahil et
    {
        options.IncludeXmlComments(xmlPath);
    }
    // Application katmanındaki DTO yorumları için de eklenebilir (opsiyonel)
    var appXmlFilename = $"{Assembly.GetAssembly(typeof(GeneralProfile))?.GetName().Name}.xml"; 
    var appXmlPath = Path.Combine(AppContext.BaseDirectory, appXmlFilename);
    if (File.Exists(appXmlPath)) options.IncludeXmlComments(appXmlPath);
});

// --- Uygulama Pipeline'ını Konfigüre Etme ---

var app = builder.Build();

app.UseMiddleware<ErrorHandlerMiddleware>();

// Geliştirme ortamı ayarları
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    // Geliştirme ortamında detaylı hata sayfası yerine global hata yöneticisi kullanılabilir.
    // app.UseDeveloperExceptionPage();
}
else
{
    // Production ortamı için global hata yönetimi middleware'i eklenebilir
    // app.UseExceptionHandler("/Error"); // Veya özel bir middleware
    app.UseHsts(); // HTTPS Strict Transport Security
}

// Global Hata Yönetimi Middleware'i (Örnek - ayrı bir dosyada olabilir)
// app.UseMiddleware<ErrorHandlerMiddleware>();

app.UseHttpsRedirection(); // HTTP isteklerini HTTPS'e yönlendir

app.UseRouting(); // Routing middleware'ini ekle

// CORS Politikası (Flutter web uygulamasının erişimi için gerekli olabilir)
// app.UseCors("AllowSpecificOrigin"); // Örnek politika adı

// Önce Authentication, sonra Authorization middleware'i eklenmeli
app.UseAuthentication(); // Kimlik doğrulama middleware'i
app.UseAuthorization(); // Yetkilendirme middleware'i

app.MapControllers(); // Controller endpoint'lerini haritala

app.Run(); // Uygulamayı çalıştır