using Application.DTOs.Debt;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// UpdateDebtDto için validasyon kuralları.
/// </summary>
public class UpdateDebtDtoValidator : AbstractValidator<UpdateDebtDto>
{
    public UpdateDebtDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Borç adı boş olamaz.")
            .MaximumLength(150).WithMessage("Borç adı en fazla 150 karakter olabilir.");

        RuleFor(x => x.LenderName)
            .MaximumLength(100).WithMessage("Alacaklı adı en fazla 100 karakter olabilir.");
    }
}