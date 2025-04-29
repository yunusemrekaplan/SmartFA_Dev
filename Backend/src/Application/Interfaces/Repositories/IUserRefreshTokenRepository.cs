using System.Linq.Expressions;
using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// UserRefreshToken entity'si için repository arayüzü.
/// </summary>
public interface IUserRefreshTokenRepository
{
    /// <summary>
    /// Belirtilen token string'ine sahip UserRefreshToken'ı getirir (ilişkili User ile birlikte).
    /// </summary>
    /// <param name="token">Aranan refresh token string'i.</param>
    /// <returns>UserRefreshToken nesnesi veya bulunamazsa null.</returns>
    Task<UserRefreshToken?> GetByTokenAsync(string token);

    /// <summary>
    /// Yeni bir UserRefreshToken ekler.
    /// </summary>
    /// <param name="refreshToken">Eklenecek UserRefreshToken nesnesi.</param>
    /// <returns>Eklenen UserRefreshToken nesnesi.</returns>
    Task<UserRefreshToken> AddAsync(UserRefreshToken refreshToken);

    /// <summary>
    /// Mevcut bir UserRefreshToken'ı günceller (genellikle RevokedAt ayarlamak için).
    /// </summary>
    /// <param name="refreshToken">Güncellenecek UserRefreshToken nesnesi.</param>
    Task UpdateAsync(UserRefreshToken refreshToken);

    /// <summary>
    /// Belirli bir kullanıcının tüm aktif (süresi dolmamış ve iptal edilmemiş) refresh token'larını getirir.
    /// </summary>
    /// <param name="userId">Kullanıcı ID'si.</param>
    /// <returns>Aktif refresh token listesi.</returns>
    Task<List<UserRefreshToken>> GetActiveTokensByUserIdAsync(int userId);

    /// <summary>
    /// Belirli bir koşula uyan UserRefreshToken listesini getirir.
    /// (AuthService'teki RevokeAllUserTokens için gerekli)
    /// </summary>
    /// <param name="predicate">Filtreleme koşulu.</param>
    /// <param name="disableTracking">Değişiklik takibini devre dışı bırakma.</param>
    /// <returns>UserRefreshToken listesi.</returns>
    Task<List<UserRefreshToken>> GetWhereAsync(Expression<Func<UserRefreshToken, bool>> predicate, bool disableTracking = true);

}