using System.Linq.Expressions;
using Core.Entities;
using Core.Entities.Core;
using Core.Enums;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Contexts;

/// <summary>
/// Uygulamanın ana veritabanı context sınıfı.
/// </summary>
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    // Entity'ler için DbSet tanımlamaları
    public DbSet<User> Users { get; set; } = null!; // Null forgiveness
    public DbSet<UserRefreshToken> UserRefreshTokens { get; set; } = null!;
    public DbSet<Account> Accounts { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Transaction> Transactions { get; set; } = null!;
    public DbSet<Budget> Budgets { get; set; } = null!;
    public DbSet<Debt> Debts { get; set; } = null!;
    public DbSet<DebtPayment> DebtPayments { get; set; } = null!;
    public DbSet<Report> Reports { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // --- Decimal Precision Ayarları ---
        foreach (var property in modelBuilder.Model.GetEntityTypes()
                     .SelectMany(t => t.GetProperties())
                     .Where(p => p.ClrType == typeof(decimal) || p.ClrType == typeof(decimal?)))
        {
            property.SetColumnType("decimal(18, 2)");
        }

        // --- İlişki Konfigürasyonları ---
        modelBuilder.Entity<Category>()
            .HasOne(c => c.User)
            .WithMany(u => u.Categories)
            .HasForeignKey(c => c.UserId)
            .OnDelete(DeleteBehavior.SetNull); // Kullanıcı silinirse özel kategorilerin UserId'si null olsun.

        modelBuilder.Entity<Account>()
            .HasOne(a => a.User)
            .WithMany(u => u.Accounts)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade); // Kullanıcı silinince hesapları da sil (Bu kalsın)

        // !!! HATA DÜZELTME: Account -> Transaction ilişkisi için OnDelete davranışını değiştir !!!
        modelBuilder.Entity<Transaction>()
            .HasOne(t => t.Account)
            .WithMany(a => a.Transactions)
            .HasForeignKey(t => t.AccountId)
            .OnDelete(DeleteBehavior.Restrict); // Cascade yerine Restrict kullanıldı

        // Category -> Transaction ilişkisi (Kategori silinince işlemler ne olacak?)
        modelBuilder.Entity<Transaction>()
            .HasOne(t => t.Category)
            .WithMany(c => c.Transactions)
            .HasForeignKey(t => t.CategoryId)
            .OnDelete(DeleteBehavior.Restrict); // Kategori silinince ilişkili işlem varsa silmeyi engelle (Öneri)

        // User -> Transaction ilişkisi (Bu Cascade kalabilir, çünkü Account yolu kırıldı)
        modelBuilder.Entity<Transaction>()
            .HasOne(t => t.User)
            .WithMany(u => u.Transactions)
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade); // Kullanıcı silinince işlemleri de sil

        // User -> Budget ilişkisi
        modelBuilder.Entity<Budget>()
            .HasOne(b => b.User)
            .WithMany(u => u.Budgets)
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Cascade); // Kullanıcı silinince bütçeleri de sil

        // Category -> Budget ilişkisi
        modelBuilder.Entity<Budget>()
            .HasOne(b => b.Category)
            .WithMany(c => c.Budgets)
            .HasForeignKey(b => b.CategoryId)
            .OnDelete(DeleteBehavior.Restrict); // Kategori silinince ilişkili bütçe varsa silmeyi engelle (Öneri)


        // User -> Debt ilişkisi
        modelBuilder.Entity<Debt>()
            .HasOne(d => d.User)
            .WithMany(u => u.Debts)
            .HasForeignKey(d => d.UserId)
            .OnDelete(DeleteBehavior.Cascade); // Kullanıcı silinince borçları da sil

        // Debt -> DebtPayment ilişkisi
        modelBuilder.Entity<DebtPayment>()
            .HasOne(dp => dp.Debt)
            .WithMany(d => d.Payments)
            .HasForeignKey(dp => dp.DebtId)
            .OnDelete(DeleteBehavior.Cascade); // Borç silinince ödemeleri de sil (Soft delete kullanıldığı için bu OK)


        // --- Soft Delete Global Query Filter ---
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .HasQueryFilter(GenerateQueryFilterLambda(entityType.ClrType));
            }
        }


        // --- Veri Tohumlama (Seeding) ---
        SeedData(modelBuilder);
    }

    /// <summary>
    /// SaveChangesAsync çağrıldığında otomatik olarak CreatedAt ve UpdatedAt alanlarını ayarlar.
    /// </summary>
    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = now;
                    entry.Entity.UpdatedAt = null;
                    entry.Entity.IsDeleted = false;
                    break;

                case EntityState.Modified:
                    // Soft delete işlemi Repository'de yapıldıysa, IsDeleted=true ve State=Modified gelir.
                    // Sadece UpdatedAt'i ayarlamak yeterli.
                    entry.Entity.UpdatedAt = now;
                    // CreatedAt'in değiştirilmediğinden emin olalım.
                    entry.Property(nameof(BaseEntity.CreatedAt)).IsModified = false;
                    break;

                case EntityState.Deleted:
                    // Soft delete kullandığımız için bu duruma gelinmemeli.
                    // Gelirse, Repository'deki DeleteAsync mantığında bir sorun olabilir.
                    throw new InvalidOperationException(
                        $"Entity {entry.Entity.GetType().Name} with ID {entry.Property("Id").CurrentValue} was marked as Deleted. Soft delete should be used.");
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }


    // --- Yardımcı Metotlar ---

    /// <summary>
    /// Soft Delete için dinamik Query Filter lambda ifadesi oluşturur.
    /// </summary>
    private static LambdaExpression GenerateQueryFilterLambda(Type type)
    {
        var parameter = Expression.Parameter(type, "e");
        var propertyMethodInfo = typeof(BaseEntity).GetProperty(nameof(BaseEntity.IsDeleted))?.GetGetMethod();
        if (propertyMethodInfo == null)
            throw new InvalidOperationException($"Property '{nameof(BaseEntity.IsDeleted)}' not found on BaseEntity.");

        var isDeletedProperty = Expression.Property(parameter, propertyMethodInfo);
        var notExpression = Expression.Not(isDeletedProperty);
        var lambda = Expression.Lambda(notExpression, parameter);
        return lambda;
    }


    /// <summary>
    /// Başlangıç verilerini (Ön tanımlı kategoriler vb.) ekler.
    /// </summary>
    private void SeedData(ModelBuilder modelBuilder)
    {
        // Kategori Enum isimlerini düzelt (Varsayım: Core.Enums altında)
        var expenseType = CategoryType.Expense; // Veya Core.Enums.CategoryType.Gider
        var incomeType = CategoryType.Income; // Veya Core.Enums.CategoryType.Gelir

        // --- Ön Tanımlı Gider Kategorileri ---
        modelBuilder.Entity<Category>().HasData(
            new Category
            {
                Id = -1, Name = "Market", Type = expenseType, IconName = "fas fa-shopping-cart", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -2, Name = "Faturalar", Type = expenseType, IconName = "fas fa-file-invoice-dollar", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -3, Name = "Ulaşım", Type = expenseType, IconName = "fas fa-bus", IsPredefined = true, CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -4, Name = "Yeme-İçme", Type = expenseType, IconName = "fas fa-utensils", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -5, Name = "Kira", Type = expenseType, IconName = "fas fa-home", IsPredefined = true, CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -6, Name = "Sağlık", Type = expenseType, IconName = "fas fa-heartbeat", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -7, Name = "Eğitim", Type = expenseType, IconName = "fas fa-graduation-cap", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -8, Name = "Giyim", Type = expenseType, IconName = "fas fa-tshirt", IsPredefined = true, CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -9, Name = "Eğlence", Type = expenseType, IconName = "fas fa-film", IsPredefined = true, CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -10, Name = "Diğer Giderler", Type = expenseType, IconName = "fas fa-ellipsis-h", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            }
        );

        // --- Ön Tanımlı Gelir Kategorileri ---
        modelBuilder.Entity<Category>().HasData(
            new Category
            {
                Id = -11, Name = "Maaş", Type = incomeType, IconName = "fas fa-briefcase", IsPredefined = true, CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -12, Name = "Ek Gelir", Type = incomeType, IconName = "fas fa-hand-holding-usd", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = -13, Name = "Diğer Gelirler", Type = incomeType, IconName = "fas fa-ellipsis-h", IsPredefined = true,
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}