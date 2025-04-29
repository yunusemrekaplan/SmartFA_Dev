using Application.Interfaces.Repositories;
using Core.Entities;
using Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Repositories;

public class UserRepository : IUserRepository
{
    private readonly ApplicationDbContext _dbContext;

    public UserRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _dbContext.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        // Email karşılaştırması büyük/küçük harf duyarsız olmalı
        return await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
    }

    public async Task<User> AddAsync(User user)
    {
        await _dbContext.Users.AddAsync(user);
        // SaveChangesAsync burada çağrılmaz.
        return user;
    }

    public Task UpdateAsync(User user)
    {
        _dbContext.Entry(user).State = EntityState.Modified;
        // SaveChangesAsync burada çağrılmaz.
        return Task.CompletedTask;
    }
}