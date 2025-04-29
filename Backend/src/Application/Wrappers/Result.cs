namespace Application.Wrappers;

/// <summary>
/// Servis metotlarının sonucunu sarmalamak için genel bir yapı.
/// </summary>
public class Result<T>
{
    public bool IsSuccess { get; protected set; }
    public T? Value { get; protected set; }
    public List<string> Errors { get; protected set; } = new List<string>();

    protected Result()
    {
    }

    public static Result<T> Success(T value) => new Result<T> { IsSuccess = true, Value = value };
    public static Result<T> Failure(List<string> errors) => new Result<T> { IsSuccess = false, Errors = errors };
    public static Result<T> Failure(string error) => new Result<T> { IsSuccess = false, Errors = new List<string> { error } };
}

/// <summary>
/// Sadece başarı/hata durumu döndüren metotlar için Result yapısı.
/// </summary>
public class Result
{
    public bool IsSuccess { get; protected set; }
    public List<string> Errors { get; protected set; } = new List<string>();

    protected Result()
    {
    }

    public static Result Success() => new Result { IsSuccess = true };
    public static Result Failure(List<string> errors) => new Result { IsSuccess = false, Errors = errors };
    public static Result Failure(string error) => new Result { IsSuccess = false, Errors = new List<string> { error } };
}