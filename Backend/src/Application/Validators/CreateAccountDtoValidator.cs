using Application.DTOs.Account;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// CreateAccountDto için validasyon kuralları.
/// </summary>
public class CreateAccountDtoValidator : AbstractValidator<CreateAccountDto>
{
    public CreateAccountDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Hesap adı boş olamaz.")
            .MaximumLength(100).WithMessage("Hesap adı en fazla 100 karakter olabilir.");

        RuleFor(x => x.Type)
            .IsInEnum().WithMessage("Geçersiz hesap türü."); // Enum değerlerinden biri olmalı

        RuleFor(x => x.Currency)
            .NotEmpty().WithMessage("Para birimi boş olamaz.")
            .Length(3).WithMessage("Para birimi kodu 3 karakter olmalıdır (örn: TRY).");

        RuleFor(x => x.InitialBalance)
            .NotNull().WithMessage("Başlangıç bakiyesi boş olamaz.");
        // .GreaterThanOrEqualTo(0).WithMessage("Başlangıç bakiyesi negatif olamaz."); // Kredi kartı için negatif olabilir? Kural gözden geçirilmeli.
    }
}