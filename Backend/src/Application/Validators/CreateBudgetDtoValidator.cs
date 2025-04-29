using Application.DTOs.Budget;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// CreateBudgetDto için validasyon kuralları.
/// </summary>
public class CreateBudgetDtoValidator : AbstractValidator<CreateBudgetDto>
{
    public CreateBudgetDtoValidator()
    {
        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Geçerli bir kategori ID'si belirtilmelidir.");

        RuleFor(x => x.Amount)
            .GreaterThan(0).WithMessage("Bütçe tutarı sıfırdan büyük olmalıdır.");

        RuleFor(x => x.Month)
            .InclusiveBetween(1, 12).WithMessage("Ay 1 ile 12 arasında olmalıdır.");

        RuleFor(x => x.Year)
            .GreaterThanOrEqualTo(DateTime.UtcNow.Year - 5)
            .WithMessage($"Yıl en az {DateTime.UtcNow.Year - 5} olabilir.") // Geçmişe dönük 5 yıl limit (örnek)
            .LessThanOrEqualTo(DateTime.UtcNow.Year + 1)
            .WithMessage($"Yıl en fazla {DateTime.UtcNow.Year + 1} olabilir."); // Gelecek 1 yıl limit (örnek)
    }
}