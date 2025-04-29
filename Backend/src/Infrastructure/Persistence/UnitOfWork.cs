using Application.Interfaces;
using Application.Interfaces.Repositories;
using Infrastructure.Persistence.Contexts;
using Infrastructure.Persistence.Repositories;

namespace Infrastructure.Persistence;

/// <summary>
/// IUnitOfWork arayüzünün EF Core implementasyonu.
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private bool _disposed = false; // Dispose durumunu takip etmek için

    // Repository'ler için backing fields (Lazy loading için)
    private IUserRepository? _userRepository;
    private IUserRefreshTokenRepository? _userRefreshTokenRepository;
    private IAccountRepository? _accountRepository;
    private ICategoryRepository? _categoryRepository;
    private ITransactionRepository? _transactionRepository;
    private IBudgetRepository? _budgetRepository;
    private IDebtRepository? _debtRepository;
    private IDebtPaymentRepository? _debtPaymentRepository;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    // Repository Property Implementasyonları (Lazy Instantiation)
    // İlgili repository ilk kez istendiğinde oluşturulur.
    public IUserRepository Users => _userRepository ??= new UserRepository(_context);
    public IUserRefreshTokenRepository UserRefreshTokens => _userRefreshTokenRepository ??= new UserRefreshTokenRepository(_context);
    public IAccountRepository Accounts => _accountRepository ??= new AccountRepository(_context);
    public ICategoryRepository Categories => _categoryRepository ??= new CategoryRepository(_context);
    public ITransactionRepository Transactions => _transactionRepository ??= new TransactionRepository(_context);
    public IBudgetRepository Budgets => _budgetRepository ??= new BudgetRepository(_context);
    public IDebtRepository Debts => _debtRepository ??= new DebtRepository(_context);
    public IDebtPaymentRepository DebtPayments => _debtPaymentRepository ??= new DebtPaymentRepository(_context);


    /// <summary>
    /// Yapılan tüm değişiklikleri tek bir transaction içinde kaydeder.
    /// </summary>
    public async Task<int> CompleteAsync()
    {
        // Burada transaction yönetimi eklenebilir (BeginTransaction, Commit, Rollback)
        // Örneğin:
        // using var transaction = await _context.Database.BeginTransactionAsync();
        // try
        // {
        //     var result = await _context.SaveChangesAsync();
        //     await transaction.CommitAsync();
        //     return result;
        // }
        // catch
        // {
        //     await transaction.RollbackAsync();
        //     throw; // Hatanın yukarıya iletilmesi
        // }

        // Basit implementasyon (transaction olmadan):
        return await _context.SaveChangesAsync();
    }

    // IDisposable Implementasyonu
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this); // Garbage Collector'ın tekrar dispose etmesini engelle
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                // Yönetilen kaynakları (DbContext) serbest bırak
                _context.Dispose();
            }
            // Yönetilmeyen kaynaklar burada serbest bırakılır (varsa)
        }

        _disposed = true;
    }

    // Opsiyonel: Açık transaction yönetimi metotları
    /*
    public async Task BeginTransactionAsync() { ... }
    public async Task CommitAsync() { ... }
    public async Task RollbackAsync() { ... }
    */
}