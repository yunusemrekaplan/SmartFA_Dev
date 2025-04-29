using Application.DTOs.Budget;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// UpdateBudgetDto için validasyon kuralları.
/// </summary>
public class UpdateBudgetDtoValidator : AbstractValidator<UpdateBudgetDto>
{
    public UpdateBudgetDtoValidator()
    {
        RuleFor(x => x.Amount)
            .GreaterThan(0).WithMessage("Bütçe tutarı sıfırdan büyük olmalıdır.");
    }
}