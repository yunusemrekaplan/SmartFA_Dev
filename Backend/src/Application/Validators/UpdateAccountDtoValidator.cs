using Application.DTOs.Account;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// UpdateAccountDto için validasyon kuralları.
/// </summary>
public class UpdateAccountDtoValidator : AbstractValidator<UpdateAccountDto>
{
    public UpdateAccountDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Hesap adı boş olamaz.")
            .MaximumLength(100).WithMessage("Hesap adı en fazla 100 karakter olabilir.");
    }
}