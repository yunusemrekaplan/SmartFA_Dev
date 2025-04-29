using Application.DTOs.Transaction;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// CreateTransactionDto için validasyon kuralları.
/// </summary>
public class CreateTransactionDtoValidator : AbstractValidator<CreateTransactionDto>
{
    public CreateTransactionDtoValidator()
    {
        RuleFor(x => x.AccountId)
            .GreaterThan(0).WithMessage("Geçerli bir hesap ID'si belirtilmelidir.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Geçerli bir kategori ID'si belirtilmelidir.");

        RuleFor(x => x.Amount)
            .NotEqual(0).WithMessage("İşlem tutarı sıfır olamaz."); // Pozitif veya negatif olabilir

        RuleFor(x => x.TransactionDate)
            .NotEmpty().WithMessage("İşlem tarihi boş olamaz.")
            .LessThanOrEqualTo(DateTime.UtcNow.AddDays(1))
            .WithMessage("İşlem tarihi gelecekten çok ileride olamaz."); // Küçük bir gelecek payı

        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Notlar en fazla 500 karakter olabilir.");
    }
}