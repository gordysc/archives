# .NET 10 & C# 14 Modern Features Reference

> Covers .NET 10 (LTS), C# 14, EF Core 10, and ASP.NET Core 10 (November 2025). Runtime: Chromium-free, ships with Visual Studio 2026.

---

## C# 14 Language Features

### Extension Members

The headline feature. The `extension` keyword replaces the old `this` parameter pattern and enables extension **properties**, **operators**, and **static members** — not just methods.

```csharp
public static class StringExtensions
{
    extension(string s)
    {
        public bool IsNullOrEmpty => string.IsNullOrEmpty(s);
        public int WordCount => s.Split(' ', StringSplitOptions.RemoveEmptyEntries).Length;
    }
}

// Usage:
"Hello World".WordCount // 2
```

Static extensions (no receiver name):

```csharp
public static class Enumerable
{
    extension<TSource>(IEnumerable<TSource>)
    {
        public static IEnumerable<TSource> operator +(
            IEnumerable<TSource> left, IEnumerable<TSource> right)
            => left.Concat(right);
    }
}

var combined = listA + listB;
```

Extension blocks must live inside a `static class`. Named receiver = instance members. No name = static members. You cannot add fields via extensions.

### `field` Keyword

Direct access to the compiler-synthesized backing field of an auto-property. No more manual `_backing` fields for simple validation.

```csharp
public string Name
{
    get => field;
    set => field = value?.Trim() ?? throw new ArgumentNullException();
}
```

If your type already has a symbol named `field`, use `@field` to refer to the identifier.

### Null-Conditional Assignment

`?.` and `?[]` can now appear on the left-hand side of assignments. The right-hand side is only evaluated if the left is not null.

```csharp
customer?.Order = GetCurrentOrder();
customer?.Total += CalculateIncrement();
customers?[0].Name = "Updated";
```

Works with `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `<<=`, `>>=`, `>>>=`. `++`/`--` are **not** allowed on the LHS with `?.`.

### User-Defined Compound Assignment Operators

Define `+=`, `-=`, `++`, `--`, etc. as void-returning instance methods that mutate in place.

```csharp
public record class GateAttendance(string GateId)
{
    public int Count { get; set; }

    public static GateAttendance operator +(GateAttendance gate, int partySize)
        => gate with { Count = gate.Count + partySize };

    // Mutate in place, return void
    public void operator +=(int partySize) => Count += partySize;
    public void operator ++() => Count++;
}
```

Compiler checks for a user-defined compound operator first, then falls back to `a = a + b`.

### Implicit Span Conversions

`T[]`, `Span<T>`, and `ReadOnlySpan<T>` are now first-class citizens with implicit conversions between them.

```csharp
void ProcessKey(ReadOnlySpan<char> key) { /* ... */ }

string line = Console.ReadLine()!;
ProcessKey(line[..5]); // implicit conversion, no .AsSpan() needed

// Generic type inference works too
static double CalcStdDev(ReadOnlySpan<int> values) { /* ... */ }
var sd = CalcStdDev(new[] { 3, 5, 3 }); // array -> ReadOnlySpan<int> inferred
```

### Simple Lambda Parameters with Modifiers

Add `ref`, `in`, `out`, `scoped`, `ref readonly` to lambda parameters without specifying the type.

```csharp
delegate bool TryParse<T>(string text, out T result);

TryParse<int> parse = (text, out result) => int.TryParse(text, out result);

delegate void ApplyDiscount(ref decimal price);
ApplyDiscount apply20 = (ref price) => price *= 0.8m;
```

### Partial Constructors and Events

Extends `partial` to instance constructors and events — designed for source generators.

```csharp
// Defining declaration
public partial class Config
{
    public partial Config(string configPath);
}

// Implementing declaration (e.g., source-generated)
public partial class Config
{
    public partial Config(string configPath)
    {
        LoadFromFile(configPath);
    }
}
```

### `nameof` with Unbound Generics

```csharp
var name = nameof(List<>);          // "List"
var name2 = nameof(Dictionary<,>);  // "Dictionary"
```

### File-Based Apps (`dotnet run app.cs`)

Single `.cs` files run without a `.csproj` or `.sln`. New `#:` directives configure the build.

```csharp
#!/usr/bin/env dotnet
#:sdk Microsoft.NET.Sdk.Web
#:package Spectre.Console@*
#:project ../SharedLib/SharedLib.csproj
#:property PublishAot=false

using Spectre.Console;
AnsiConsole.MarkupLine("[green]Hello from a single file![/]");
```

```bash
dotnet run app.cs              # run
dotnet publish app.cs          # native AOT by default
dotnet pack app.cs             # package as .NET tool
dotnet project convert app.cs  # convert to traditional .csproj
echo 'Console.WriteLine("hi");' | dotnet run -  # pipe from stdin
```

---

## Runtime & JIT

### Stack Allocation (Escape Analysis)

The JIT stack-allocates small, fixed-sized arrays of value types **and** reference types when escape analysis proves they don't outlive their scope:

```csharp
int[] numbers = {1, 2, 3};       // stack-allocated
string[] words = {"Hello", "!"};  // stack-allocated when proven safe
```

Extended to struct fields referencing objects — if the struct doesn't escape, neither does the referenced object. Also applies to `Func` delegates that don't outlive their scope.

### JIT Improvements

- **Struct argument packing**: Promoted struct members placed into shared registers directly, eliminating memory round-trips
- **Array interface devirtualization**: `IEnumerable<T>` over arrays optimized to indexed `for` loops
- **Inlining**: Methods with `try-finally` can now be inlined; relaxed size limits with profile data; return type precision enables further devirtualization
- **Code layout**: Block reordering modeled as asymmetric TSP with 3-opt heuristic for near-optimal hot path density
- **Loop inversion**: Graph-based natural loop recognition replaces lexical analysis
- **AVX10.2**: New intrinsics in `System.Runtime.Intrinsics.X86.Avx10v2`

### DATAS GC (Default)

Dynamic Adaptation To Application Sizes is now the default GC mode. Automatically adjusts memory usage — reduces consumption during light workloads, increases during peaks.

```xml
<!-- Disable if needed for batch/analytics or ultra-low-latency workloads -->
<GarbageCollectionAdaptationMode>0</GarbageCollectionAdaptationMode>
```

### Arm64 Write-Barrier Improvements

Dynamic write-barrier switching (previously x64-only) now on Arm64. Benchmarks show **8–20%+ GC pause improvements**.

### NativeAOT

- Android startup: ~300ms (NativeAOT) vs ~1.3s (MonoAOT)
- Published executables around 1 MB; deployment artifacts reduced up to 60%
- Preinitializer supports all `conv.*` and `neg` opcodes
- `webapiaot` template includes OpenAPI support by default

---

## ASP.NET Core 10

### OpenAPI 3.1 (Default)

Full OpenAPI 3.1 support with JSON Schema draft 2020-12:

```csharp
builder.Services.AddOpenApi(options =>
{
    options.OpenApiVersion = Microsoft.OpenApi.OpenApiSpecVersion.OpenApi3_1;
});

// YAML output
app.MapOpenApi("/openapi/{documentName}.yaml");
```

XML doc comments automatically populate descriptions. `Microsoft.OpenApi` upgraded to 2.0.0 (`OpenApiAny` replaced with `JsonNode`).

### Server-Sent Events

Built-in SSE support for Minimal APIs:

```csharp
app.MapGet("/heartrate", (CancellationToken ct) =>
{
    async IAsyncEnumerable<HeartRateRecord> Stream(
        [EnumeratorCancellation] CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            yield return HeartRateRecord.Create(Random.Shared.Next(60, 100));
            await Task.Delay(2000, ct);
        }
    }
    return TypedResults.ServerSentEvents(Stream(ct), eventType: "heartRate");
});
```

### Built-in Validation

```csharp
builder.Services.AddValidation();

app.MapPost("/products",
    ([EvenNumber(ErrorMessage = "Product ID must be even")] int productId,
     [Required] string name) => TypedResults.Ok(productId));

// Disable per-endpoint
app.MapPost("/products", handler).DisableValidation();
```

Supports `DataAnnotations`, `IValidatableObject`, record types, and custom attributes. Returns 400 with `ProblemDetails`.

### Passkey/WebAuthn Authentication

ASP.NET Core Identity now supports FIDO2/WebAuthn passkeys. Configure via `IdentityPasskeyOptions` (ServerDomain, AuthenticatorTimeout, ChallengeSize).

### API Cookie Behavior

Endpoints with `IApiEndpointMetadata` (`[ApiController]`, Minimal APIs with JSON, SignalR) return **401/403** instead of redirecting to login pages.

### Memory Pool Management

Automatic eviction of idle blocks from Kestrel/IIS/HTTP.sys memory pools. New `IMemoryPoolFactory<byte>` in DI:

```csharp
public class MyService(IMemoryPoolFactory<byte> factory)
{
    private readonly MemoryPool<byte> _pool = factory.Create();
}
```

### PipeReader JSON Parsing

MVC and Minimal APIs automatically use `PipeReader`-based JSON deserialization for improved throughput on large payloads.

---

## Blazor

### `[PersistentState]` Attribute

Declarative state persistence replacing manual `PersistentComponentState`:

```csharp
@code {
    [PersistentState]
    public List<Movie>? MoviesList { get; set; }

    protected override async Task OnInitializedAsync()
    {
        MoviesList ??= await MovieService.GetMoviesAsync();
    }
}
```

Options: `AllowUpdates = true` for enhanced navigation, `RestoreBehavior` for skipping prerender/reconnection snapshots, `RegisterPersistentService<T>()` for service-level persistence.

### Circuit State Persistence

Session state persists across connection loss (browser tab throttling, mobile app switching, network interruptions).

### JavaScript Interop Enhancements

```csharp
var obj = await JSRuntime.InvokeConstructorAsync("jsInterop.TestClass", "Blazor!");
var val = await JSRuntime.GetValueAsync<int>("jsInterop.testObject.num");
await JSRuntime.SetValueAsync("jsInterop.testObject.num", 30);
```

### Router 404 Handling

```razor
<Router NotFoundPage="typeof(Pages.NotFound)">
```

Plus `NavigationManager.NotFound()` method for programmatic 404s across SSR, interactive, and streaming rendering.

### Source-Generated Validation

```csharp
builder.Services.AddValidation();

[ValidatableType]
public class Order
{
    public Customer Customer { get; set; } = new();
    public List<OrderItem> OrderItems { get; set; } = [];
}
```

### WebAssembly Improvements

- `blazor.web.js` as static asset with compression/fingerprinting — **76% size reduction** (183 KB to 43 KB)
- Framework assets preloaded via `Link` headers
- `blazor.boot.json` inlined into `dotnet.js`
- Response streaming enabled by default

---

## Entity Framework Core 10

### LINQ `LeftJoin` and `RightJoin`

```csharp
var query = context.Students
    .LeftJoin(
        context.Enrollments,
        student => student.Id,
        enrollment => enrollment.StudentId,
        (student, enrollment) => new { student.Name, enrollment.Course });
```

Also available in `System.Linq` for in-memory collections.

### Native JSON Type

Maps to SQL Server 2025/Azure SQL native `json` type. Full `ExecuteUpdate` support for JSON column properties:

```csharp
context.Orders
    .Where(o => o.Id == orderId)
    .ExecuteUpdate(s => s.SetProperty(o => o.ShippingAddress.City, "New York"));
```

Complex types can map directly to JSON columns.

### Vector Data Type

Full support for `vector` and `VECTOR_DISTANCE()` on Azure SQL / SQL Server 2025 for AI-ready vector search.

### Named Query Filters

```csharp
modelBuilder.Entity<Blog>()
    .HasQueryFilter("SoftDelete", b => !b.IsDeleted)
    .HasQueryFilter("Tenant", b => b.TenantId == currentTenantId);
```

### Cosmos DB

Default values for missing required properties, Full-Text Search integration, hybrid semantic + full-text search.

---

## BCL & Libraries

### Post-Quantum Cryptography

FIPS 203, 204, 205 implementations — `MLKem`, `MLDsa`, `SlhDsa`:

```csharp
using MLKem key = MLKem.GenerateKey(MLKemAlgorithm.MLKem768);
string pem = key.ExportSubjectPublicKeyInfoPem();

using MLDsa key = MLDsa.ImportFromPem(publicKeyPem);
bool valid = key.VerifyData(data, signature);
```

Windows CNG support, HashML-DSA, Composite ML-DSA, AES KeyWrap with Padding.

### LINQ Additions

- **`LeftJoin` / `RightJoin`**: First-class join operators
- **`Shuffle`**: New randomization operator
- **`System.Linq.AsyncEnumerable`**: Complete LINQ implementation for `IAsyncEnumerable<T>`, built into .NET 10

### System.Text.Json

- **`JsonSerializerOptions.Strict`**: Rejects ambiguous/loose JSON and duplicate property names
- **JSON Patch**: New STJ-native implementation replacing Newtonsoft-based `Microsoft.AspNetCore.JsonPatch`
- **`PipeReader` support**: Streaming deserialization via `System.IO.Pipelines`
- **15–20% faster serialization** with 25% less allocation

### ZipArchive

- Update mode no longer loads all entries into memory
- Parallelized extraction
- New async APIs

### Networking

- Multiple concurrent HTTP/3 connections per `HttpClient`
- `WebSocketStream` class for simplified WebSocket usage
- TLS 1.3 client support on macOS
- `HttpClient.DefaultProxy` auto-updates from Windows registry changes

---

## SDK & Tooling

### SLNX Default Format

`dotnet new sln` creates `.slnx` (XML-based) files by default:

```xml
<Solution>
  <Project Path="src\MyApp\MyApp.csproj" />
  <Project Path="tests\MyApp.Tests\MyApp.Tests.csproj" />
</Solution>
```

Revert with `--format sln`.

### `dotnet tool exec`

One-shot tool execution without installation — useful for CI/CD:

```bash
dotnet tool exec <tool-name> [args]
```

### Container Publishing

Console apps create container images without `EnableSdkContainerSupport`:

```bash
dotnet publish /t:PublishContainer
```

New `ContainerImageFormat` property (`.Docker` or `.OCI`).

### Multi-Platform .NET Tools

Tools can bundle binaries for multiple `RuntimeIdentifiers` in a single NuGet package.

### Tab Completion

Native scripts for bash, fish, PowerShell, zsh, and nushell.

---

## Removed & Deprecated APIs

| API | Status | Replacement |
| --- | --- | --- |
| `WithOpenApi()` | Deprecated | Compile-time diagnostic issued |
| `WebHostBuilder` / `IWebHost` / `WebHost` | Deprecated | `WebApplicationBuilder` |
| `BlazorCacheBootResources` MSBuild property | Removed | Static asset fingerprinting |
| APIs marked `[Obsolete]` in .NET 8/9 | Removed | See individual replacements |
| `OpenApiAny` | Removed | `JsonNode` (Microsoft.OpenApi 2.0) |
| MAUI `TableView` | Deprecated | `CollectionView` |
| MAUI `MessagingCenter` | Deprecated | `WeakReferenceMessenger` (CommunityToolkit.Mvvm) |

---

## Breaking Changes

- `dotnet new sln` creates `.slnx` format by default
- Blazor response streaming enabled by default (`ReadAsStreamAsync` returns `BrowserHttpReadStream`)
- Cookie auth for API endpoints returns 401/403 instead of redirecting
- EF Core: Primitive collections and owned types mapped to JSON use native `json` instead of `nvarchar(max)`
- Exception handler no longer logs exceptions handled by `IExceptionHandler` returning `true`

---

## Version Info

| Component | Version |
| --- | --- |
| .NET | 10 (LTS — supported through November 2028) |
| C# | 14 |
| ASP.NET Core | 10 |
| EF Core | 10 |
| MAUI | 10 |
| Visual Studio | 2026 |
