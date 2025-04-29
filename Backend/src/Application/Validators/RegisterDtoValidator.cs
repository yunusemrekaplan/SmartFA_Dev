using Application.DTOs.Authentication;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// RegisterDto için validasyon kuralları.
/// </summary>
public class RegisterDtoValidator : AbstractValidator<RegisterDto>
{
    public RegisterDtoValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-posta adresi boş olamaz.")
            .EmailAddress().WithMessage("Geçerli bir e-posta adresi giriniz.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Şifre boş olamaz.")
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter uzunluğunda olmalıdır.");
        // Daha karmaşık şifre kuralları eklenebilir (büyük harf, küçük harf, sayı, özel karakter vb.)
        // .Matches("[A-Z]").WithMessage("Şifre en az bir büyük harf içermelidir.")
        // .Matches("[a-z]").WithMessage("Şifre en az bir küçük harf içermelidir.")
        // .Matches("[0-9]").WithMessage("Şifre en az bir rakam içermelidir.");

        RuleFor(x => x.ConfirmPassword)
            .NotEmpty().WithMessage("Şifre tekrarı boş olamaz.")
            .Equal(x => x.Password).WithMessage("Şifreler eşleşmiyor.");
    }
}