using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddReport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Reports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    Period = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    FilterCriteria = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GeneratedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FilePath = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsScheduled = table.Column<bool>(type: "bit", nullable: false),
                    ScheduleCron = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reports_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -13,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(4108));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -12,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(4107));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -11,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(4105));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -10,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1355));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -9,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1353));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -8,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1352));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -7,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1315));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -6,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1314));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -5,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1313));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -4,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1312));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1311));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1310));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2025, 5, 27, 5, 57, 16, 609, DateTimeKind.Utc).AddTicks(1223));

            migrationBuilder.CreateIndex(
                name: "IX_Reports_UserId",
                table: "Reports",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Reports");

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -13,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(4834));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -12,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(4833));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -11,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(4831));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -10,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2159));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -9,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2158));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -8,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2157));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -7,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2156));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -6,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2100));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -5,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2099));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -4,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2098));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2097));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2096));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 29, 23, 30, 15, 623, DateTimeKind.Utc).AddTicks(2010));
        }
    }
}
