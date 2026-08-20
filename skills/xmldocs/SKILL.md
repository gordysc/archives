---
name: xmldocs
description: Adds XML documentation comments to .NET classes, interfaces, methods, and properties. Generates summary, param, returns, remarks, and exception tags. Use when asked to document code, add XML docs, add documentation comments, or improve code documentation in C# files.
---

# Documenting .NET Code

Adds comprehensive XML documentation comments to C# code following .NET conventions and project style guidelines.

## Quick Start

1. Read the target file to understand existing code structure
2. Identify undocumented or under-documented elements
3. Add XML documentation following the element-specific formats below
4. Preserve all existing code and formatting

## Documentation Requirements

Document ALL of the following elements:

| Element         | Required Tags                                            |
| --------------- | -------------------------------------------------------- |
| Classes         | `<summary>`                                              |
| Interfaces      | `<summary>`                                              |
| Methods         | `<summary>`, `<param>` (each), `<returns>` (if non-void) |
| Properties      | `<summary>`                                              |
| Constructors    | `<summary>`, `<param>` (each)                            |
| Events          | `<summary>`                                              |
| Fields (public) | `<summary>`                                              |
| Private methods | `<summary>`, `<param>` (each), `<returns>` (if non-void) |
| Private fields  | `<summary>`                                              |

## XML Tag Formats

### Class/Interface

```csharp
/// <summary>
/// Brief description of the class/interface purpose.
/// </summary>
public sealed class MyClass
```

### Method with Parameters and Return

```csharp
/// <summary>
/// Brief description of what the method does.
/// </summary>
/// <param name="paramName">Description of the parameter.</param>
/// <returns>Description of the return value.</returns>
public string GetValue(int paramName)
```

### Method with Exceptions

```csharp
/// <summary>
/// Brief description of what the method does.
/// </summary>
/// <param name="input">Description of the parameter.</param>
/// <returns>Description of the return value.</returns>
/// <exception cref="ArgumentNullException">Thrown when <paramref name="input"/> is null.</exception>
public string Process(string input)
```

### Property

```csharp
/// <summary>
/// Gets or sets the description of what this property represents.
/// </summary>
public string Name { get; set; }
```

### Constructor

```csharp
/// <summary>
/// Initializes a new instance of the <see cref="MyClass"/> class.
/// </summary>
/// <param name="dependency">Description of the dependency.</param>
public MyClass(IDependency dependency)
```

### Interface Method

```csharp
/// <summary>
/// Brief description of the contract this method represents.
/// </summary>
/// <param name="value">Description of the parameter.</param>
/// <returns>Description of the return value.</returns>
TResult Execute(TInput value);
```

## Writing Guidelines

1. Start `<summary>` with a verb in third person singular: "Gets", "Sets", "Creates", "Processes", "Validates"
2. End all descriptions with a period
3. Use `<see cref="TypeName"/>` to reference other types
4. Use `<paramref name="paramName"/>` to reference parameters in descriptions
5. Keep summaries concise (1-2 sentences)
6. Add `<remarks>` only for complex logic requiring additional explanation
7. Document thrown exceptions with `<exception cref="ExceptionType">`

## Common Verbs by Element Type

| Element Type      | Starting Verbs                         |
| ----------------- | -------------------------------------- |
| Get-only property | "Gets the..."                          |
| Set-only property | "Sets the..."                          |
| Get/Set property  | "Gets or sets the..."                  |
| Boolean property  | "Gets a value indicating whether..."   |
| Factory method    | "Creates a new..."                     |
| Async method      | "Asynchronously [verb]s..."            |
| Event             | "Occurs when..."                       |
| Extension method  | "Extends [type] to..."                 |
| Constructor       | "Initializes a new instance of the..." |

## Examples

<examples>
<example name="service-class">
**Input**: Undocumented service class

```csharp
public sealed class UserService
{
    private readonly IUserRepository _repository;

    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }

    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        return await _repository.FindAsync(id, cancellationToken);
    }
}
```

**Output**: Documented service class

```csharp
/// <summary>
/// Provides operations for managing user entities.
/// </summary>
public sealed class UserService
{
    private readonly IUserRepository _repository;

    /// <summary>
    /// Initializes a new instance of the <see cref="UserService"/> class.
    /// </summary>
    /// <param name="repository">The user repository for data access.</param>
    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Asynchronously retrieves a user by their unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the user.</param>
    /// <param name="cancellationToken">A token to cancel the operation.</param>
    /// <returns>The user if found; otherwise, <c>null</c>.</returns>
    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        return await _repository.FindAsync(id, cancellationToken);
    }
}
```

</example>

<example name="interface">
**Input**: Undocumented interface

```csharp
public interface IHaveTimestamps
{
    DateTimeOffset CreatedAt { get; }
    DateTimeOffset UpdatedAt { get; }
}
```

**Output**: Documented interface

```csharp
/// <summary>
/// Represents an entity that tracks creation and modification timestamps.
/// </summary>
public interface IHaveTimestamps
{
    /// <summary>
    /// Gets the date and time when the entity was created.
    /// </summary>
    DateTimeOffset CreatedAt { get; }

    /// <summary>
    /// Gets the date and time when the entity was last updated.
    /// </summary>
    DateTimeOffset UpdatedAt { get; }
}
```

</example>

<example name="extension-method">
**Input**: Undocumented extension method

```csharp
public static class StringExtensions
{
    public static string Truncate(this string value, int maxLength)
    {
        if (string.IsNullOrEmpty(value)) return value;
        return value.Length <= maxLength ? value : value[..maxLength];
    }
}
```

**Output**: Documented extension method

```csharp
/// <summary>
/// Provides extension methods for <see cref="string"/> operations.
/// </summary>
public static class StringExtensions
{
    /// <summary>
    /// Truncates the string to the specified maximum length.
    /// </summary>
    /// <param name="value">The string to truncate.</param>
    /// <param name="maxLength">The maximum allowed length.</param>
    /// <returns>The original string if within length limit; otherwise, the truncated string.</returns>
    public static string Truncate(this string value, int maxLength)
    {
        if (string.IsNullOrEmpty(value)) return value;

        return value.Length <= maxLength ? value : value[..maxLength];
    }
}
```

</example>

<example name="ef-interceptor">
**Input**: Undocumented EF Core interceptor

```csharp
public sealed class TimestampInterceptor : ISaveChangesInterceptor
{
    private readonly TimeProvider _timeProvider;

    public TimestampInterceptor(TimeProvider timeProvider)
    {
        _timeProvider = timeProvider;
    }

    public ValueTask<InterceptionResult<int>> SavingChangesAsync(DbContextEventData eventData, InterceptionResult<int> result, CancellationToken cancellationToken = new())
    {
        if (eventData.Context is { } context)
        {
            AssignTimestamps(context);
        }

        return new ValueTask<InterceptionResult<int>>(result);
    }
}
```

**Output**: Documented EF Core interceptor

```csharp
/// <summary>
/// Intercepts Entity Framework Core save operations to automatically assign timestamps.
/// </summary>
public sealed class TimestampInterceptor : ISaveChangesInterceptor
{
    private readonly TimeProvider _timeProvider;

    /// <summary>
    /// Initializes a new instance of the <see cref="TimestampInterceptor"/> class.
    /// </summary>
    /// <param name="timeProvider">The time provider for generating timestamps.</param>
    public TimestampInterceptor(TimeProvider timeProvider)
    {
        _timeProvider = timeProvider;
    }

    /// <summary>
    /// Asynchronously intercepts the save changes operation to assign timestamps before persisting.
    /// </summary>
    /// <param name="eventData">The event data containing the database context.</param>
    /// <param name="result">The interception result.</param>
    /// <param name="cancellationToken">A token to cancel the operation.</param>
    /// <returns>The interception result.</returns>
    public ValueTask<InterceptionResult<int>> SavingChangesAsync(DbContextEventData eventData, InterceptionResult<int> result, CancellationToken cancellationToken = new())
    {
        if (eventData.Context is { } context)
        {
            AssignTimestamps(context);
        }

        return new ValueTask<InterceptionResult<int>>(result);
    }
}
```

</example>

<example name="partial-documentation">
**Input**: Class with partial documentation (only class summary exists)

```csharp
/// <summary>
/// Provides database persistence configuration.
/// </summary>
public static class PersistenceExtensions
{
    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>((sp, x) =>
        {
            x.UseNpgsql(configuration.GetConnectionString("Database"));
        });

        return services;
    }
}
```

**Output**: Complete documentation

```csharp
/// <summary>
/// Provides database persistence configuration.
/// </summary>
public static class PersistenceExtensions
{
    /// <summary>
    /// Adds persistence services including Entity Framework Core with PostgreSQL.
    /// </summary>
    /// <param name="services">The service collection to configure.</param>
    /// <param name="configuration">The application configuration containing connection strings.</param>
    /// <returns>The service collection for method chaining.</returns>
    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>((sp, x) =>
        {
            x.UseNpgsql(configuration.GetConnectionString("Database"));
        });

        return services;
    }
}
```

</example>
</examples>

## Constraints

<constraints>
- NEVER modify code logic, only add documentation comments
- NEVER remove existing documentation
- ALWAYS place XML comments directly above the element they document
- ALWAYS end documentation sentences with a period
- NEVER use first person ("I", "we") in documentation
- NEVER include implementation details in summaries unless critical for usage
- ALWAYS document private methods regardless of complexity
- ALWAYS use `<c>null</c>` when referencing null in documentation
- ALWAYS use `<see cref=""/>` for type references
- ALWAYS use `<paramref name=""/>` for parameter references within descriptions
</constraints>
