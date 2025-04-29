using Application.DTOs.Debt;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// CreateDebtDto için validasyon kuralları.
/// </summary>
public class CreateDebtDtoValidator : AbstractValidator<CreateDebtDto>
{
    public CreateDebtDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Borç adı boş olamaz.")
            .MaximumLength(150).WithMessage("Borç adı en fazla 150 karakter olabilir.");

        RuleFor(x => x.LenderName)
            .MaximumLength(100).WithMessage("Alacaklı adı en fazla 100 karakter olabilir.");

        RuleFor(x => x.TotalAmount)
            .GreaterThan(0).WithMessage("Toplam borç tutarı sıfırdan büyük olmalıdır.");

        RuleFor(x => x.RemainingAmount)
            .NotNull().WithMessage("Kalan bakiye boş olamaz.")
            .GreaterThanOrEqualTo(0).WithMessage("Kalan bakiye negatif olamaz.");

        // Kalan bakiyenin toplam tutardan büyük olamayacağı kontrolü
        RuleFor(x => x.RemainingAmount)
            .LessThanOrEqualTo(x => x.TotalAmount).WithMessage("Kalan bakiye, toplam borç tutarından büyük olamaz.")
            .When(x => x.TotalAmount > 0); // Sadece TotalAmount pozitifse kontrol et

        RuleFor(x => x.Currency)
            .NotEmpty().WithMessage("Para birimi boş olamaz.")
            .Length(3).WithMessage("Para birimi kodu 3 karakter olmalıdır.");
    }
}