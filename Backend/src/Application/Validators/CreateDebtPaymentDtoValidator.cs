using Application.DTOs.DebtPayment;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// CreateDebtPaymentDto için validasyon kuralları.
/// </summary>
public class CreateDebtPaymentDtoValidator : AbstractValidator<CreateDebtPaymentDto>
{
    public CreateDebtPaymentDtoValidator()
    {
        RuleFor(x => x.DebtId)
            .GreaterThan(0).WithMessage("Geçerli bir borç ID'si belirtilmelidir.");

        RuleFor(x => x.Amount)
            .GreaterThan(0).WithMessage("Ödeme tutarı sıfırdan büyük olmalıdır.");

        RuleFor(x => x.PaymentDate)
            .NotEmpty().WithMessage("Ödeme tarihi boş olamaz.")
            .LessThanOrEqualTo(DateTime.UtcNow.AddDays(1)).WithMessage("Ödeme tarihi gelecekten çok ileride olamaz.");

        RuleFor(x => x.Notes)
            .MaximumLength(200).WithMessage("Notlar en fazla 200 karakter olabilir.");
    }
}