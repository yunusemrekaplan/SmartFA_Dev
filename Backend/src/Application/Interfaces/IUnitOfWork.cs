using Application.Interfaces.Repositories;

namespace Application.Interfaces;

/// <summary>
/// Unit of Work pattern'ini temsil eden arayüz.
/// Repository'leri ve değişiklikleri kaydetme işlemini merkezi olarak yönetir.
/// </summary>
public interface IUnitOfWork : IDisposable
{
    // Repository Arayüzleri (Her bir repository için property)
    IUserRepository Users { get; }
    IUserRefreshTokenRepository UserRefreshTokens { get; }
    IAccountRepository Accounts { get; }
    ICategoryRepository Categories { get; }
    ITransactionRepository Transactions { get; }
    IBudgetRepository Budgets { get; }
    IDebtRepository Debts { get; }
    IDebtPaymentRepository DebtPayments { get; }

    /// <summary>
    /// Bir iş akışı sırasında yapılan tüm değişiklikleri veritabanına kaydeder.
    /// </summary>
    /// <returns>Etkilenen satır sayısı.</returns>
    Task<int> CompleteAsync();

    // Opsiyonel: Açık transaction yönetimi için
    // Task BeginTransactionAsync();
    // Task CommitAsync();
    // Task RollbackAsync();
}