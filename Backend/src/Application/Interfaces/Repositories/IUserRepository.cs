using Core.Entities;

namespace Application.Interfaces.Repositories;

/// <summary>
/// User entity'si için repository arayüzü.
/// Not: User, BaseEntity'den türemediği için IRepository<User> kullanamayız.
/// Ayrı metotlar tanımlanır veya farklı bir base interface kullanılır.
/// </summary>
public interface IUserRepository
{
    Task<User?> GetByIdAsync(int id);
    Task<User?> GetByEmailAsync(string email);
    Task<User> AddAsync(User user);
    Task UpdateAsync(User user);
}