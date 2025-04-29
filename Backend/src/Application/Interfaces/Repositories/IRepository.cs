using System.Linq.Expressions;
using Core.Entities.Core;

namespace Application.Interfaces.Repositories;

/// <summary>
/// Tüm repository'ler için temel generic arayüz.
/// BaseEntity'den türeyen ve soft delete destekleyen entity'ler için CRUD operasyonlarını tanımlar.
/// </summary>
/// <typeparam name="T">BaseEntity'den türeyen entity tipi</typeparam>
public interface IRepository<T> where T : BaseEntity
{
    /// <summary>
    /// Belirtilen ID'ye sahip entity'yi getirir (IsDeleted=false olanları).
    /// </summary>
    /// <param name="id">Entity ID'si</param>
    /// <returns>Entity veya bulunamazsa null</returns>
    Task<T?> GetByIdAsync(int id);

    /// <summary>
    /// Tüm entity'leri listeler (IsDeleted=false olanları).
    /// </summary>
    /// <returns>Entity listesi</returns>
    Task<IReadOnlyList<T>> GetAllAsync();

    /// <summary>
    /// Belirtilen koşula uyan entity'leri listeler (IsDeleted=false olanları).
    /// </summary>
    /// <param name="predicate">Filtreleme koşulu</param>
    /// <returns>Entity listesi</returns>
    Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>> predicate);

    /// <summary>
    /// Belirtilen koşula uyan entity'leri, sıralama ve include'larla birlikte listeler (IsDeleted=false olanları).
    /// </summary>
    /// <param name="predicate">Filtreleme koşulu (opsiyonel)</param>
    /// <param name="orderBy">Sıralama koşulu (opsiyonel)</param>
    /// <param name="includeString">İlişkili tabloları getirmek için include ifadesi (opsiyonel)</param>
    /// <param name="disableTracking">Değişiklik takibini devre dışı bırakma (opsiyonel, sadece okuma için true)</param>
    /// <returns>Entity listesi</returns>
    Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>>? predicate = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        string? includeString = null,
        bool disableTracking = true);

    /// <summary>
    /// Belirtilen koşula uyan entity'leri, sıralama ve include'larla birlikte listeler (IsDeleted=false olanları).
    /// </summary>
    /// <param name="predicate">Filtreleme koşulu (opsiyonel)</param>
    /// <param name="orderBy">Sıralama koşulu (opsiyonel)</param>
    /// <param name="includes">İlişkili tabloları getirmek için include ifadeleri listesi (opsiyonel)</param>
    /// <param name="disableTracking">Değişiklik takibini devre dışı bırakma (opsiyonel, sadece okuma için true)</param>
    /// <returns>Entity listesi</returns>
    Task<IReadOnlyList<T>> GetAsync(Expression<Func<T, bool>>? predicate = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        List<Expression<Func<T, object>>>? includes = null,
        bool disableTracking = true);

    /// <summary>
    /// Yeni bir entity ekler.
    /// </summary>
    /// <param name="entity">Eklenecek entity</param>
    /// <returns>Eklenen entity</returns>
    Task<T> AddAsync(T entity);

    /// <summary>
    /// Mevcut bir entity'yi günceller.
    /// </summary>
    /// <param name="entity">Güncellenecek entity</param>
    /// <returns></returns>
    Task UpdateAsync(T entity); // Genellikle void döner veya bool

    /// <summary>
    /// Belirtilen ID'ye sahip entity'yi siler (Soft Delete: IsDeleted=true yapar).
    /// </summary>
    /// <param name="id">Silinecek entity ID'si</param>
    /// <returns></returns>
    Task DeleteAsync(int id);

    /// <summary>
    /// Belirtilen entity'yi siler (Soft Delete: IsDeleted=true yapar).
    /// </summary>
    /// <param name="entity">Silinecek entity</param>
    /// <returns></returns>
    Task DeleteAsync(T entity);
}