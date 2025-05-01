using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddUserRefreshTokens : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "UserRefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Token = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RevokedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserRefreshTokens_Users_UserId",
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

            migrationBuilder.CreateIndex(
                name: "IX_UserRefreshTokens_UserId",
                table: "UserRefreshTokens",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserRefreshTokens");

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -13,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 779, DateTimeKind.Utc).AddTicks(2710));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -12,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 779, DateTimeKind.Utc).AddTicks(2708));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -11,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 779, DateTimeKind.Utc).AddTicks(2707));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -10,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9948));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -9,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9947));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -8,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9946));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -7,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9945));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -6,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9944));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -5,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9943));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -4,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9942));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9941));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9940));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2025, 4, 28, 16, 31, 45, 778, DateTimeKind.Utc).AddTicks(9858));
        }
    }
}
