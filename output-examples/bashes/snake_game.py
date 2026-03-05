import pygame
import random
import sys
from collections import deque

# --- Constants ---
GRID = 8
CELL = 64
WINDOW = GRID * CELL
FPS_BASE = 4
FPS_INCREMENT = 1
POINTS_PER_SPEEDUP = 10
STAR_SPAWN_CHANCE = 0.08
STAR_LIFETIME = 20

DIRECTIONS = {
    "UP": (0, -1),
    "DOWN": (0, 1),
    "LEFT": (-1, 0),
    "RIGHT": (1, 0),
}
OPPOSITES = {"UP": "DOWN", "DOWN": "UP", "LEFT": "RIGHT", "RIGHT": "LEFT"}

KEY_MAP = {
    pygame.K_w: "UP", pygame.K_UP: "UP",
    pygame.K_s: "DOWN", pygame.K_DOWN: "DOWN",
    pygame.K_a: "LEFT", pygame.K_LEFT: "LEFT",
    pygame.K_d: "RIGHT", pygame.K_RIGHT: "RIGHT",
}

# --- Colors ---
BG = (20, 20, 20)
GRID_COLOR = (40, 40, 40)
SNAKE_COLOR = (0, 200, 80)
SNAKE_HEAD = (0, 255, 100)
APPLE_COLOR = (220, 30, 30)
STAR_COLOR = (255, 215, 0)
TEXT_COLOR = (220, 220, 220)
OVERLAY_BG = (0, 0, 0, 180)


def new_game():
    mid = GRID // 2
    snake = deque([(mid, mid), (mid - 1, mid), (mid - 2, mid)])
    state = {
        "snake": snake,
        "dir": "RIGHT",
        "score": 0,
        "apple": None,
        "star": None,
        "star_timer": 0,
        "grow": 0,
        "alive": True,
        "started": False,
        "speed": 1,
    }
    state["apple"] = spawn_food(state)
    return state


def occupied_cells(state):
    cells = set(state["snake"])
    if state["apple"]:
        cells.add(state["apple"])
    if state["star"]:
        cells.add(state["star"])
    return cells


def spawn_food(state):
    occupied = set(state["snake"])
    if state["apple"]:
        occupied.add(state["apple"])
    if state["star"]:
        occupied.add(state["star"])
    free = [(x, y) for x in range(GRID) for y in range(GRID) if (x, y) not in occupied]
    if not free:
        return None
    return random.choice(free)


def tick(state, input_queue):
    if not state["alive"] or not state["started"]:
        return

    # Pop next direction from queue
    if input_queue:
        state["dir"] = input_queue.popleft()

    dx, dy = DIRECTIONS[state["dir"]]
    hx, hy = state["snake"][0]
    nx, ny = hx + dx, hy + dy

    # Wall collision
    if nx < 0 or nx >= GRID or ny < 0 or ny >= GRID:
        state["alive"] = False
        return

    # Self collision: check against all segments except tail (which will vacate
    # if not growing). If growing, tail stays — check the full body.
    check = set(state["snake"]) if state["grow"] > 0 else set(list(state["snake"])[:-1])
    if (nx, ny) in check:
        state["alive"] = False
        return

    # Move head
    state["snake"].appendleft((nx, ny))

    # Check food
    if (nx, ny) == state["apple"]:
        state["score"] += 1
        state["grow"] += 1
        state["apple"] = spawn_food(state)

    if state["star"] and (nx, ny) == state["star"]:
        state["score"] += 3
        state["grow"] += 3
        state["star"] = None
        state["star_timer"] = 0

    # Grow or shed tail
    if state["grow"] > 0:
        state["grow"] -= 1
    else:
        state["snake"].pop()

    # Speed
    state["speed"] = 1 + state["score"] // POINTS_PER_SPEEDUP

    # Star logic
    if state["star"]:
        state["star_timer"] -= 1
        if state["star_timer"] <= 0:
            state["star"] = None
            state["star_timer"] = 0
    elif random.random() < STAR_SPAWN_CHANCE:
        state["star"] = spawn_food(state)
        if state["star"]:
            state["star_timer"] = STAR_LIFETIME


def enqueue_direction(input_queue, new_dir, current_dir):
    # Validate against the effective facing direction (last queued or current)
    effective = input_queue[-1] if input_queue else current_dir
    if new_dir == OPPOSITES.get(effective):
        return  # Self-collision move, reject
    if new_dir == effective:
        return  # No-op
    input_queue.append(new_dir)


def draw(screen, state, font):
    screen.fill(BG)

    # Grid lines
    for i in range(GRID + 1):
        pygame.draw.line(screen, GRID_COLOR, (i * CELL, 0), (i * CELL, WINDOW))
        pygame.draw.line(screen, GRID_COLOR, (0, i * CELL), (WINDOW, i * CELL))

    # Apple
    if state["apple"]:
        ax, ay = state["apple"]
        center = (ax * CELL + CELL // 2, ay * CELL + CELL // 2)
        pygame.draw.circle(screen, APPLE_COLOR, center, CELL // 2 - 4)

    # Star
    if state["star"]:
        sx, sy = state["star"]
        draw_star(screen, sx * CELL + CELL // 2, sy * CELL + CELL // 2, CELL // 2 - 4)

    # Snake
    for i, (x, y) in enumerate(state["snake"]):
        color = SNAKE_HEAD if i == 0 else SNAKE_COLOR
        rect = pygame.Rect(x * CELL + 2, y * CELL + 2, CELL - 4, CELL - 4)
        pygame.draw.rect(screen, color, rect, border_radius=6)

    # HUD
    hud = font.render(f"Score: {state['score']}   Speed: {state['speed']}", True, TEXT_COLOR)
    screen.blit(hud, (8, WINDOW + 8))

    # Overlays
    if not state["started"]:
        draw_overlay(screen, font, "SNAKE", "Press ENTER to start")
    elif not state["alive"]:
        draw_overlay(screen, font, f"GAME OVER — Score: {state['score']}", "Press ENTER to restart")


def draw_star(screen, cx, cy, r):
    import math
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        radius = r if i % 2 == 0 else r * 0.45
        points.append((cx + radius * math.cos(angle), cy - radius * math.sin(angle)))
    pygame.draw.polygon(screen, STAR_COLOR, points)


def draw_overlay(screen, font, title, subtitle):
    overlay = pygame.Surface((WINDOW, WINDOW + 40), pygame.SRCALPHA)
    overlay.fill(OVERLAY_BG)
    screen.blit(overlay, (0, 0))

    title_surf = font.render(title, True, TEXT_COLOR)
    sub_surf = font.render(subtitle, True, TEXT_COLOR)
    screen.blit(title_surf, (WINDOW // 2 - title_surf.get_width() // 2, WINDOW // 2 - 30))
    screen.blit(sub_surf, (WINDOW // 2 - sub_surf.get_width() // 2, WINDOW // 2 + 10))


def main():
    pygame.init()
    screen = pygame.display.set_mode((WINDOW, WINDOW + 40))
    pygame.display.set_caption("Snake")
    clock = pygame.time.Clock()
    font = pygame.font.SysFont("monospace", 22)

    state = new_game()
    input_queue = deque()

    while True:
        fps = FPS_BASE + (state["speed"] - 1) * FPS_INCREMENT

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RETURN:
                    if not state["started"]:
                        state["started"] = True
                        input_queue.clear()
                    elif not state["alive"]:
                        state = new_game()
                        state["started"] = True
                        input_queue.clear()
                elif event.key in KEY_MAP and state["started"] and state["alive"]:
                    enqueue_direction(input_queue, KEY_MAP[event.key], state["dir"])

        tick(state, input_queue)
        draw(screen, state, font)
        pygame.display.flip()
        clock.tick(fps)


if __name__ == "__main__":
    main()
