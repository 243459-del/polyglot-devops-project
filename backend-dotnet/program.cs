var builder = WebApplication.CreateBuilder(args);

// CORS allow karna zaroori hai taake Frontend isse data fetch kar sake
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

var app = builder.Build();

app.UseCors("AllowAll");

// 1. Status Endpoint
app.MapGet("/api/status", () => new { status = "Healthy", message = ".NET API is running smoothly!" });

// 2. Tasks Endpoint (Sample Data)
app.MapGet("/api/tasks", () => new[]
{
    new { id = 1, title = "Setup Project Structure", done = true },
    new { id = 2, title = "Containerize Frontend & Backend", done = false },
    new { id = 3, title = "Configure Terraform & Cloud", done = false }
});

app.Run("http://0.0.0.0:5000");