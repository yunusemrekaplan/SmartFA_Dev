using Application.DTOs.Account;
using Application.DTOs.Budget;
using Application.DTOs.Category;
using Application.DTOs.Debt;
using Application.DTOs.DebtPayment;
using Application.DTOs.Reports;
using Application.DTOs.Transaction;
using AutoMapper;
using Core.Entities;

namespace Application.Mappings;

/// <summary>
/// Uygulamadaki DTO ve Entity nesneleri arasındaki AutoMapper dönüşümlerini tanımlar.
/// </summary>
public class GeneralProfile : Profile
{
    public GeneralProfile()
    {
        // --- Account Mappings ---
        CreateMap<Account, AccountDto>()
            // AccountDto'daki CurrentBalance, servis katmanında hesaplandığı için burada map edilmez.
            // Eğer Account entity'sinde CurrentBalance olsaydı: .ForMember(dest => dest.CurrentBalance, opt => opt.MapFrom(src => src.CurrentBalance))
            // Enum'dan string'e dönüşüm (AccountType -> string)
            .ForMember(dest => dest.Type, opt => opt.MapFrom(src => src.Type));
        CreateMap<CreateAccountDto, Account>(); // InitialBalance map edilir.
        CreateMap<UpdateAccountDto, Account>()
            // Sadece map edilmesi gereken alanları belirtmek için (opsiyonel ama güvenli)
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name))
            // Diğer alanları ignore et (Id, UserId, Type, Currency, InitialBalance vb. güncellenmemeli)
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.Type, opt => opt.Ignore())
            .ForMember(dest => dest.Currency, opt => opt.Ignore())
            .ForMember(dest => dest.InitialBalance, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
            .ForMember(dest => dest.User, opt => opt.Ignore())
            .ForMember(dest => dest.Transactions, opt => opt.Ignore());


        // --- Transaction Mappings ---
        CreateMap<Transaction, TransactionDto>()
            // İlişkili nesnelerden isimleri/ikonları almak için
            .ForMember(dest => dest.AccountName, opt => opt.MapFrom(src => src.Account.Name))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name))
            .ForMember(dest => dest.CategoryIcon, opt => opt.MapFrom(src => src.Category.IconName))
            .ForMember(dest => dest.CategoryType,
                opt => opt.MapFrom(src => src.Category.Type)); // Category null ise default
        CreateMap<CreateTransactionDto, Transaction>();
        CreateMap<UpdateTransactionDto, Transaction>()
            .ForMember(dest => dest.Id, opt => opt.Ignore()) // Id, UserId, CreatedAt vb. ignore edilir
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
            .ForMember(dest => dest.User, opt => opt.Ignore())
            .ForMember(dest => dest.Account, opt => opt.Ignore()) // Navigation property'ler
            .ForMember(dest => dest.Category, opt => opt.Ignore());


        // --- Category Mappings ---
        CreateMap<Category, CategoryDto>(); // Enum (CategoryType) otomatik map edilir (isimler eşleşiyorsa)
        CreateMap<CreateCategoryDto, Category>();
        CreateMap<UpdateCategoryDto, Category>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.Type, opt => opt.Ignore()) // Tip güncellenmez
            .ForMember(dest => dest.IsPredefined, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
            .ForMember(dest => dest.User, opt => opt.Ignore())
            .ForMember(dest => dest.Transactions, opt => opt.Ignore())
            .ForMember(dest => dest.Budgets, opt => opt.Ignore());


        // --- Budget Mappings ---
        CreateMap<Budget, BudgetDto>()
            // CategoryName, CategoryIcon, SpentAmount, RemainingAmount servis katmanında doldurulur, burada ignore edilebilir veya map edilebilir.
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name))
            .ForMember(dest => dest.CategoryIcon, opt => opt.MapFrom(src => src.Category.IconName))
            .ForMember(dest => dest.SpentAmount, opt => opt.Ignore()) // Serviste hesaplanacak
            .ForMember(dest => dest.RemainingAmount, opt => opt.Ignore()); // Serviste hesaplanacak
        CreateMap<CreateBudgetDto, Budget>();
        CreateMap<UpdateBudgetDto, Budget>()
            .ForMember(dest => dest.Amount, opt => opt.MapFrom(src => src.Amount)) // Sadece Amount güncellenir
            .ForAllMembers(opts => opts.Condition((_, _, srcMember) => srcMember != null)); // Diğerlerini ignore etmenin bir yolu
        /* Veya tek tek ignore:
        .ForMember(dest => dest.Id, opt => opt.Ignore())
        .ForMember(dest => dest.UserId, opt => opt.Ignore())
        .ForMember(dest => dest.CategoryId, opt => opt.Ignore())
        .ForMember(dest => dest.Month, opt => opt.Ignore())
        .ForMember(dest => dest.Year, opt => opt.Ignore())
        // ... BaseEntity alanları ve Navigation Property'ler ...
        */


        // --- Debt Mappings ---
        CreateMap<Debt, DebtDto>();
        CreateMap<CreateDebtDto, Debt>();
        CreateMap<UpdateDebtDto, Debt>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.TotalAmount, opt => opt.Ignore()) // Bu alanlar güncellenmez
            .ForMember(dest => dest.RemainingAmount, opt => opt.Ignore())
            .ForMember(dest => dest.Currency, opt => opt.Ignore())
            .ForMember(dest => dest.IsPaidOff, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
            .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
            .ForMember(dest => dest.User, opt => opt.Ignore())
            .ForMember(dest => dest.Payments, opt => opt.Ignore());


        // --- DebtPayment Mappings ---
        CreateMap<DebtPayment, DebtPaymentDto>();
        CreateMap<CreateDebtPaymentDto, DebtPayment>();
        // DebtPayment için genellikle Update olmaz, silinip yeniden eklenebilir veya ayrı bir düzeltme mekanizması kurulur.


        // --- Report Mappings ---
        CreateMap<Report, ReportDto>()
            .ForMember(dest => dest.TypeName, opt => opt.Ignore()) // Serviste doldurulacak
            .ForMember(dest => dest.PeriodName, opt => opt.Ignore()); // Serviste doldurulacak

        // --- Auth/User Mappings (Gerekirse) ---
        // RegisterDto'dan User'a map etme (PasswordHash hariç)
        // CreateMap<RegisterDto, User>()
        //    .ForMember(dest => dest.PasswordHash, opt => opt.Ignore()); // Hashleme serviste yapılır
    }
}