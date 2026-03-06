"""Snake game — pygame frontend."""

import math
import pygame
import sys
from model import Game, GameState, Dir, Pos

# Layout
CELL = 64
BOARD = 8
GRID_SIZE = CELL * BOARD
MARGIN = 24
HUD_HEIGHT = 40
WIN_W = GRID_SIZE + MARGIN * 2
WIN_H = GRID_SIZE + MARGIN * 2 + HUD_HEIGHT

# Colors
BG = (30, 30, 40)
GRID_LINE = (45, 45, 55)
SNAKE_HEAD = (100, 210, 100)
SNAKE_BODY = (60, 160, 60)
APPLE_COLOR = (220, 60, 60)
STAR_YELLOW = (240, 210, 50)
STAR_RED = (220, 50, 50)
TEXT_COLOR = (200, 200, 210)
DIM_OVERLAY = (0, 0, 0, 140)
WIN_GOLD = (255, 215, 0)
WIN_GLOW = (255, 235, 100)
DEATH_COLOR = (200, 50, 50)

# Pygame key -> direction mapping
KEY_MAP = {
    pygame.K_w: Dir.UP, pygame.K_UP: Dir.UP,
    pygame.K_s: Dir.DOWN, pygame.K_DOWN: Dir.DOWN,
    pygame.K_a: Dir.LEFT, pygame.K_LEFT: Dir.LEFT,
    pygame.K_d: Dir.RIGHT, pygame.K_RIGHT: Dir.RIGHT,
}


def cell_rect(pos: Pos) -> pygame.Rect:
    return pygame.Rect(MARGIN + pos.col * CELL, MARGIN + HUD_HEIGHT + pos.row * CELL, CELL, CELL)


def draw_board(surface: pygame.Surface):
    for r in range(BOARD + 1):
        y = MARGIN + HUD_HEIGHT + r * CELL
        pygame.draw.line(surface, GRID_LINE, (MARGIN, y), (MARGIN + GRID_SIZE, y))
    for c in range(BOARD + 1):
        x = MARGIN + c * CELL
        pygame.draw.line(surface, GRID_LINE, (x, MARGIN + HUD_HEIGHT), (x, MARGIN + HUD_HEIGHT + GRID_SIZE))


def draw_snake(surface: pygame.Surface, game: Game, win_glow=False):
    for i, pos in enumerate(game.body):
        r = cell_rect(pos)
        inset = r.inflate(-4, -4)
        if win_glow:
            color = WIN_GLOW if (i + pygame.time.get_ticks() // 100) % 2 else WIN_GOLD
        elif i == len(game.body) - 1:
            color = SNAKE_HEAD
        else:
            color = SNAKE_BODY
        pygame.draw.rect(surface, color, inset, border_radius=6)


def draw_apple(surface: pygame.Surface, pos: Pos):
    center = cell_rect(pos).center
    pygame.draw.circle(surface, APPLE_COLOR, center, CELL // 2 - 6)


def draw_star(surface: pygame.Surface, pos: Pos, warning: bool):
    """Draw a 5-pointed star shape."""
    cx, cy = cell_rect(pos).center
    color = STAR_RED if warning else STAR_YELLOW
    r_out = CELL // 2 - 6
    r_in = r_out * 0.4
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = r_out if i % 2 == 0 else r_in
        points.append((cx + r * math.cos(angle), cy - r * math.sin(angle)))
    pygame.draw.polygon(surface, color, points)


def draw_hud(surface: pygame.Surface, game: Game, font: pygame.font.Font):
    score_text = font.render(f"Score: {game.score}", True, TEXT_COLOR)
    level_text = font.render(f"Level: {game.level}", True, TEXT_COLOR)
    surface.blit(score_text, (MARGIN, MARGIN // 2))
    surface.blit(level_text, (WIN_W - MARGIN - level_text.get_width(), MARGIN // 2))


def draw_overlay_text(surface: pygame.Surface, lines: list[str], font_large: pygame.font.Font, font_small: pygame.font.Font):
    overlay = pygame.Surface((WIN_W, WIN_H), pygame.SRCALPHA)
    overlay.fill(DIM_OVERLAY)
    surface.blit(overlay, (0, 0))

    total_height = sum(font_large.get_height() if i == 0 else font_small.get_height() for i in range(len(lines)))
    spacing = 8
    total_height += spacing * (len(lines) - 1)
    y = (WIN_H - total_height) // 2

    for i, line in enumerate(lines):
        font = font_large if i == 0 else font_small
        text = font.render(line, True, TEXT_COLOR)
        x = (WIN_W - text.get_width()) // 2
        surface.blit(text, (x, y))
        y += font.get_height() + spacing


def main():
    pygame.init()
    screen = pygame.display.set_mode((WIN_W, WIN_H))
    pygame.display.set_caption("Snake")
    clock = pygame.time.Clock()

    font_large = pygame.font.SysFont("monospace", 32, bold=True)
    font_small = pygame.font.SysFont("monospace", 18)
    font_hud = pygame.font.SysFont("monospace", 20, bold=True)

    game = Game()
    keys_held: set[int] = set()
    tick_accumulator = 0.0
    death_freeze_timer = 0
    win_timer = 0
    DEATH_FREEZE_MS = 500
    WIN_DISPLAY_MS = 5000

    while True:
        dt = clock.tick(60)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYDOWN:
                if game.state == GameState.START:
                    if event.key == pygame.K_RETURN:
                        game.start()
                        tick_accumulator = 0.0
                elif game.state == GameState.GAME_OVER and death_freeze_timer <= 0:
                    if event.key == pygame.K_RETURN:
                        game = Game()
                        game.start()
                        tick_accumulator = 0.0
                        keys_held.clear()
                elif game.state == GameState.WIN and win_timer <= 0:
                    if event.key == pygame.K_RETURN:
                        game = Game()
                        game.start()
                        tick_accumulator = 0.0
                        keys_held.clear()
                elif game.state in (GameState.PLAYING, GameState.PAUSED):
                    if event.key == pygame.K_SPACE:
                        game.toggle_pause()
                    elif event.key in KEY_MAP and event.key not in keys_held:
                        keys_held.add(event.key)
                        game.enqueue(KEY_MAP[event.key])

            if event.type == pygame.KEYUP:
                keys_held.discard(event.key)

        # Tick accumulation (only while playing)
        if game.state == GameState.PLAYING:
            tick_accumulator += dt
            while tick_accumulator >= game.tick_interval_ms:
                tick_accumulator -= game.tick_interval_ms
                game.tick()
                if game.state == GameState.GAME_OVER:
                    death_freeze_timer = DEATH_FREEZE_MS
                    break
                if game.state == GameState.WIN:
                    win_timer = WIN_DISPLAY_MS
                    break

        if death_freeze_timer > 0:
            death_freeze_timer -= dt

        if win_timer > 0:
            win_timer -= dt

        # Draw
        screen.fill(BG)
        draw_board(screen)

        if game.state == GameState.START:
            draw_overlay_text(screen, [
                "SNAKE",
                "WASD / Arrows to move",
                "Space to pause",
                "Press Enter to start",
            ], font_large, font_small)

        elif game.state == GameState.WIN:
            draw_snake(screen, game, win_glow=True)
            draw_hud(screen, game, font_hud)
            if win_timer <= 0:
                draw_overlay_text(screen, [
                    "YOU WIN!",
                    f"Score: {game.score}",
                    "Press Enter to play again",
                ], font_large, font_small)
            else:
                # Show "YOU WIN" during glow period too
                overlay = pygame.Surface((WIN_W, WIN_H), pygame.SRCALPHA)
                text = font_large.render("YOU WIN!", True, WIN_GOLD)
                x = (WIN_W - text.get_width()) // 2
                y = (WIN_H - text.get_height()) // 2
                overlay.blit(text, (x, y))
                screen.blit(overlay, (0, 0))

        elif game.state == GameState.GAME_OVER:
            draw_snake(screen, game)
            if game.death_pos is not None:
                dp = game.death_pos
                if 0 <= dp.col < BOARD and 0 <= dp.row < BOARD:
                    r = cell_rect(dp).inflate(-4, -4)
                    pygame.draw.rect(screen, DEATH_COLOR, r, width=3, border_radius=6)
            if game.apple:
                draw_apple(screen, game.apple)
            if game.star:
                draw_star(screen, game.star, game.star_is_warning)
            draw_hud(screen, game, font_hud)
            if death_freeze_timer <= 0:
                draw_overlay_text(screen, [
                    "GAME OVER",
                    f"Score: {game.score}",
                    "Press Enter to play again",
                ], font_large, font_small)

        else:  # PLAYING or PAUSED
            draw_snake(screen, game)
            if game.apple:
                draw_apple(screen, game.apple)
            if game.star:
                draw_star(screen, game.star, game.star_is_warning)
            draw_hud(screen, game, font_hud)
            if game.state == GameState.PAUSED:
                draw_overlay_text(screen, ["PAUSED"], font_large, font_small)

        pygame.display.flip()


if __name__ == "__main__":
    main()
