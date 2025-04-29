using Application.DTOs.Category;
using FluentValidation;

namespace Application.Validators;

/// <summary>
/// UpdateCategoryDto için validasyon kuralları.
/// </summary>
public class UpdateCategoryDtoValidator : AbstractValidator<UpdateCategoryDto>
{
    public UpdateCategoryDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Kategori adı boş olamaz.")
            .MaximumLength(100).WithMessage("Kategori adı en fazla 100 karakter olabilir.");

        RuleFor(x => x.IconName)
            .NotEmpty().WithMessage("İkon adı boş olamaz.")
            .MaximumLength(50).WithMessage("İkon adı en fazla 50 karakter olabilir.");
    }
}