"""Generates `assets/models/{ally,enemy}_<UnitKind.name>.json` Lottie files
that faithfully port the static shape geometry from
`lib/features/allies/presentation/ally_sprites.dart` and
`lib/features/enemies/presentation/enemy_sprites.dart`.

Each `*_unit` function below mirrors one Dart `_paint*` method line-for-line
(same `size`/`center` variables, same multipliers) so it can be diffed
against the source by eye. Run with:

    tool/lottie_gen/.venv/bin/python3 tool/lottie_gen/gen_units.py
"""
import os

from lottie_shapes import (
    bounds,
    circle,
    ellipse,
    fill,
    gradient_fill,
    line_shape,
    op,
    polygon,
    rect,
    rrect,
    stroke,
    write_layer,
    write_svg,
)

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "models")

# Plain SVGs, not a runtime asset - source material to hand-import into an
# external vector/rigging tool (e.g. Rive) and animate from there.
SVG_OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "models_svg")

# --- shared building blocks ------------------------------------------------


def shadow(cx, cy, w, h, argb=0x40000000):
    return op(ellipse(cx, cy, w, h), fill(argb))


def legs(cx, cy, s, color):
    return [
        op(rrect(cx + dx, cy + 0.28 * s, 0.1 * s, 0.26 * s, 3), fill(color))
        for dx in (-0.075 * s, 0.075 * s)
    ]


def torso(cx, cy, s, colors):
    pts = [
        (cx - 0.26 * s, cy - 0.2 * s),
        (cx + 0.26 * s, cy - 0.2 * s),
        (cx + 0.17 * s, cy + 0.2 * s),
        (cx - 0.17 * s, cy + 0.2 * s),
    ]
    bx, by, bw, bh = bounds(pts)
    return polygon(pts), gradient_fill(colors, bx, by, bw, bh, "vertical")


def shoulder_pads(cx, cy, s, color_left, color_right=None):
    color_right = color_left if color_right is None else color_right
    return [
        op(rrect(cx + dx, cy - 0.18 * s, 0.13 * s, 0.1 * s, 2), fill(c))
        for dx, c in zip((-0.24 * s, 0.24 * s), (color_left, color_right))
    ]


def rifle(cx, cy, s, width):
    return op(
        line_shape((cx + 0.14 * s, cy - 0.12 * s), (cx + 0.34 * s, cy - 0.46 * s)),
        stroke(0xFF1A1A1A, width, round_cap=True),
    )


def helmet(cx, cy, s, dark, light, visor_bg, glint_color, glint_alpha=None, r_back=0.16, r_front=0.14):
    ops = [
        op(circle(cx, cy - 0.3 * s, r_back * s), fill(dark)),
        op(circle(cx, cy - 0.32 * s, r_front * s), fill(light)),
    ]
    vw, vh = 0.22 * s, 0.05 * s
    vcx, vcy = cx, cy - 0.3 * s
    ops.append(op(rrect(vcx, vcy, vw, vh, 2), fill(visor_bg)))
    gcx, gcy = vcx - vw * 0.22, vcy - 0.6
    ops.append(op(rrect(gcx, gcy, vw * 0.32, vh * 0.5, 1), fill(glint_color, alpha=glint_alpha)))
    return ops


def wheel_grid(cx, cy, s, dxs, dys, w, h, r, color=0xFF0D0D0D):
    return [
        op(rrect(cx + dx, cy + dy, w, h, r), fill(color))
        for dy in dys
        for dx in dxs
    ]


# --- ally (cyan livery) ------------------------------------------------

HULL = 0xFF2B3A42
HULL_DARK = 0xFF172126
ACCENT = 0xFF00E5FF


def _mirror_x(points, cx):
    """The left/right mirror of `points` around the vertical axis `cx`,
    in reverse order so a polygon built as `right + mirrored` stays a
    simple (non-self-intersecting) outline."""
    return [(2 * cx - x, y) for (x, y) in reversed(points)]


def jet(light, mid, dark, accent, exhaust):
    """Top-down fighter jet (nose up): swept main wings, tailplanes,
    tapered fuselage, canopy, intakes, wingtip missiles and twin engine
    nozzles. Shared by the ally Aircraft and the enemy Attack Plane (only
    the palette differs). Mirrors `paintJet` in
    `lib/core/rendering/util/paint_jet.dart`."""
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.04 * s, cy + 0.07 * s, 0.5 * s, 0.72 * s, 0x2A000000)]

    # Swept main wings (right half, then mirrored left half).
    right_wing = [
        (cx + 0.07 * s, cy - 0.06 * s),
        (cx + 0.47 * s, cy + 0.27 * s),
        (cx + 0.47 * s, cy + 0.37 * s),
        (cx + 0.09 * s, cy + 0.25 * s),
    ]
    wing = polygon(right_wing + _mirror_x(right_wing, cx))
    ops.append(op(wing, gradient_fill([light, mid, dark], cx, cy, 0.94 * s, 0.4 * s, "vertical")))
    ops.append(op(wing, stroke(accent, 1.0, alpha=0.55)))

    # Tailplanes.
    right_tail = [
        (cx + 0.07 * s, cy + 0.3 * s),
        (cx + 0.23 * s, cy + 0.43 * s),
        (cx + 0.22 * s, cy + 0.47 * s),
        (cx + 0.06 * s, cy + 0.4 * s),
    ]
    ops.append(op(polygon(right_tail), fill(dark)))
    ops.append(op(polygon(_mirror_x(right_tail, cx)), fill(dark)))

    # Twin vertical fins seen edge-on.
    for dx in (-0.06 * s, 0.06 * s):
        ops.append(op(rrect(cx + dx, cy + 0.34 * s, 0.025 * s, 0.17 * s, 1), fill(dark)))

    # Wingtip missiles.
    for dx in (-0.41 * s, 0.41 * s):
        ops.append(op(rrect(cx + dx, cy + 0.27 * s, 0.035 * s, 0.15 * s, 2), fill(0xFFECEFF1)))
        ops.append(op(circle(cx + dx, cy + 0.2 * s, 0.02 * s), fill(accent)))

    # Fuselage - tapered nose to tail.
    right_body = [
        (cx, cy - 0.47 * s),
        (cx + 0.05 * s, cy - 0.3 * s),
        (cx + 0.08 * s, cy - 0.05 * s),
        (cx + 0.075 * s, cy + 0.3 * s),
        (cx + 0.05 * s, cy + 0.44 * s),
    ]
    body = polygon(right_body + _mirror_x(right_body[1:], cx))
    ops.append(op(body, gradient_fill([dark, mid, light, mid, dark], cx, cy, 0.17 * s, 0.9 * s, "horizontal")))
    ops.append(op(body, stroke(dark, 0.8, alpha=0.8)))

    # Intakes.
    for dx in (-0.07 * s, 0.07 * s):
        ops.append(op(rrect(cx + dx, cy + 0.04 * s, 0.03 * s, 0.1 * s, 1.5), fill(0xFF11161A)))

    # Canopy with a highlight.
    ops.append(op(ellipse(cx, cy - 0.16 * s, 0.1 * s, 0.22 * s), fill(0xFF14202B)))
    ops.append(op(ellipse(cx - 0.01 * s, cy - 0.19 * s, 0.045 * s, 0.1 * s), fill(accent, alpha=0.55)))

    # Spine stripe in the team colour.
    ops.append(op(rrect(cx, cy + 0.14 * s, 0.025 * s, 0.22 * s, 1), fill(accent, alpha=0.85)))

    # Twin engine nozzles with glow.
    for dx in (-0.035 * s, 0.035 * s):
        ops.append(op(circle(cx + dx, cy + 0.45 * s, 0.05 * s), fill(exhaust, alpha=0.55)))
        ops.append(op(circle(cx + dx, cy + 0.43 * s, 0.032 * s), fill(0xFF0D0F10)))
    return ops, s, s


def ally_aircraft():
    return jet(0xFFA9BCC6, 0xFF3F5660, HULL_DARK, ACCENT, 0xFF00E5FF)


def ally_anti_air():
    s = 48.0
    cx = cy = s / 2
    weapon = 0xFFFFB300
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(weapon, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(op(line_shape((cx + 0.04 * s, cy - 0.12 * s), (cx + 0.36 * s, cy - 0.5 * s)),
                  stroke(0xFF2B2B2B, 5, round_cap=True)))
    ops.append(op(circle(cx + 0.36 * s, cy - 0.5 * s, 0.06 * s), fill(weapon)))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, weapon, glint_alpha=0.9)
    return ops, s, s


def ally_anti_tank():
    s = 48.0
    cx = cy = s / 2
    weapon = 0xFFFF5252
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(weapon, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(op(line_shape((cx - 0.02 * s, cy - 0.14 * s), (cx + 0.44 * s, cy - 0.24 * s)),
                  stroke(0xFF2B2B2B, 6, round_cap=True)))
    ops.append(op(circle(cx + 0.44 * s, cy - 0.24 * s, 0.07 * s), fill(weapon)))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, weapon, glint_alpha=0.9)
    return ops, s, s


def ally_soldier():
    s = 48.0
    cx = cy = s / 2
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(ACCENT, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(rifle(cx, cy, s, 3))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, ACCENT, glint_alpha=0.9)
    return ops, s, s


def ally_tank():
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.36 * s, 0.36 * s), (0,), 0.14 * s, 0.66 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.68 * s, 0.46 * s, 8), gradient_fill([HULL, HULL_DARK], cx, cy, 0.68 * s, 0.46 * s, "vertical")))
    ops.append(op(rrect(cx, cy, 0.68 * s, 0.46 * s, 8), stroke(ACCENT, 1.5, alpha=0.8)))
    turret = circle(cx, cy - 0.04 * s, 0.2 * s)
    ops.append(op(turret, gradient_fill([HULL, HULL_DARK], cx, cy, 0.4 * s, 0.4 * s, "horizontal")))
    ops.append(op(turret, stroke(ACCENT, 1.5)))
    ops.append(op(rrect(cx, cy - 0.34 * s, 0.1 * s, 0.4 * s, 3), fill(0xFF1A1C20)))
    return ops, s, s


def ally_light_vehicle():
    s = 46.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.8 * s, 0.26 * s)]
    ops.append(op(rrect(cx, cy, 0.56 * s, 0.6 * s, 8), gradient_fill([HULL, HULL_DARK], cx, cy, 0.56 * s, 0.6 * s, "vertical")))
    ops.append(op(rrect(cx, cy, 0.56 * s, 0.6 * s, 8), stroke(ACCENT, 1.5, alpha=0.8)))
    ops.append(op(rrect(cx, cy - 0.14 * s, 0.32 * s, 0.16 * s, 3), fill(ACCENT, alpha=0.55)))
    ops.append(op(rrect(cx, cy + 0.06 * s, 0.08 * s, 0.26 * s, 2), fill(0xFF1A1C20)))
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (-0.22 * s, 0.22 * s), 0.12 * s, 0.2 * s, 2)
    return ops, s, s


def drone(light, hull, hull_dark, accent):
    """Top-down MQ-9 Reaper-style UAV: long tapered straight wings with
    under-wing pods, a bulbous sensor nose, slim body, inverted V-tail and a
    blurred pusher propeller. Mirrors `paintUav` in
    `lib/core/rendering/util/paint_uav.dart` (`accent` is the sensor-lens
    and marking colour: cyan for ally, red for enemy)."""
    s = 42.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.04 * s, cy + 0.07 * s, 0.7 * s, 0.5 * s, 0x26000000)]

    # Long, slightly tapered straight wings.
    right_wing = [
        (cx + 0.08 * s, cy - 0.05 * s),
        (cx + 0.48 * s, cy - 0.01 * s),
        (cx + 0.48 * s, cy + 0.07 * s),
        (cx + 0.08 * s, cy + 0.11 * s),
    ]
    wing = polygon(right_wing + _mirror_x(right_wing, cx))
    ops.append(op(wing, gradient_fill([light, hull, hull_dark], cx, cy, 0.96 * s, 0.16 * s, "vertical")))
    ops.append(op(wing, stroke(hull_dark, 0.8, alpha=0.9)))

    # Under-wing hardpoint pods + wingtip marking.
    for dx in (-0.27 * s, 0.27 * s):
        ops.append(op(ellipse(cx + dx, cy + 0.04 * s, 0.045 * s, 0.15 * s), fill(0xFF1A1C20)))
    for dx in (-0.44 * s, 0.44 * s):
        ops.append(op(rrect(cx + dx, cy + 0.03 * s, 0.05 * s, 0.07 * s, 1), fill(accent, alpha=0.85)))

    # Inverted V-tail.
    right_tail = [
        (cx + 0.025 * s, cy + 0.28 * s),
        (cx + 0.2 * s, cy + 0.42 * s),
        (cx + 0.16 * s, cy + 0.45 * s),
        (cx + 0.02 * s, cy + 0.36 * s),
    ]
    ops.append(op(polygon(right_tail), fill(hull_dark)))
    ops.append(op(polygon(_mirror_x(right_tail, cx)), fill(hull_dark)))

    # Slim fuselage with a bulbous nose.
    right_body = [
        (cx, cy - 0.44 * s),
        (cx + 0.085 * s, cy - 0.33 * s),
        (cx + 0.09 * s, cy - 0.2 * s),
        (cx + 0.06 * s, cy - 0.05 * s),
        (cx + 0.04 * s, cy + 0.36 * s),
    ]
    body = polygon(right_body + _mirror_x(right_body[1:], cx))
    ops.append(op(body, gradient_fill([hull_dark, hull, light, hull, hull_dark], cx, cy, 0.18 * s, 0.8 * s, "horizontal")))
    ops.append(op(body, stroke(hull_dark, 0.7, alpha=0.9)))

    # Sensor ball under the nose + dorsal antenna.
    ops.append(op(circle(cx, cy - 0.33 * s, 0.065 * s), fill(0xFF1A1C20)))
    ops.append(op(circle(cx, cy - 0.33 * s, 0.04 * s), fill(accent, alpha=0.9)))
    ops.append(op(rrect(cx, cy - 0.08 * s, 0.02 * s, 0.1 * s, 1), fill(light, alpha=0.9)))

    # Pusher propeller: hub plus a faint spinning disc.
    ops.append(op(ellipse(cx, cy + 0.41 * s, 0.3 * s, 0.06 * s), fill(0xFFFFFFFF, alpha=0.18)))
    ops.append(op(circle(cx, cy + 0.39 * s, 0.045 * s), fill(0xFF1A1C20)))
    return ops, s, s


def ally_drone():
    return drone(0xFFA9BCC6, 0xFF3F5660, HULL_DARK, ACCENT)


def enemy_drone():
    return drone(0xFFC9C7A4, 0xFF8A8868, 0xFF33321F, 0xFFE53935)


def ally_rocket_barrage():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.86 * s, 0.3 * s)]
    body = cx, cy + 0.1 * s
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6),
                  gradient_fill([HULL, HULL_DARK], body[0], body[1], 0.62 * s, 0.56 * s, "vertical")))
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6), stroke(ACCENT, 1.5, alpha=0.8)))
    pod = cx, cy - 0.22 * s
    ops.append(op(rrect(pod[0], pod[1], 0.5 * s, 0.3 * s, 4), fill(0xFF37474F)))
    for dx in (-0.16 * s, 0.0, 0.16 * s):
        ops.append(op(circle(cx + dx, cy - 0.22 * s, 0.06 * s), fill(ACCENT, alpha=0.9)))
    ops += wheel_grid(cx, cy, s, (-0.32 * s, 0.32 * s), (-0.06 * s, 0.32 * s), 0.14 * s, 0.22 * s, 2)
    return ops, s, s


# --- enemy (green infantry / grey-brown vehicles) --------------------------


def enemy_infantry(heavy: bool):
    s = 60.0 if heavy else 48.0
    cx = cy = s / 2
    body = 0xFF33691E if heavy else 0xFF4C7A2A
    dark = 0xFF1B3D0F if heavy else 0xFF2E4B18
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, dark)
    shape, style = torso(cx, cy, s, [body, dark])
    ops.append(op(shape, style))
    if heavy:
        ops.append(op(rrect(cx, cy + 0.02 * s, 0.22 * s, 0.24 * s, 4), fill(0xFF263A17)))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(dark, 2)))
    pad = 0xFFB71C1C if heavy else dark
    ops += shoulder_pads(cx, cy, s, pad)
    ops.append(rifle(cx, cy, s, 4 if heavy else 3))
    ops += helmet(cx, cy, s, dark, body, 0xFF0D1A06, 0xCCBEEFFF, r_back=0.17, r_front=0.15)
    return ops, s, s


def enemy_anti_air_vehicle():
    s = 52.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.06 * s,), 0.13 * s, 0.6 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.58 * s, 0.4 * s, 6),
                  gradient_fill([0xFF78909C, 0xFF263238], cx, cy, 0.58 * s, 0.4 * s, "vertical")))
    for dx in (-0.08 * s, 0.08 * s):
        ops.append(op(rrect(cx + dx, cy - 0.3 * s, 0.07 * s, 0.32 * s, 2), fill(0xFF2B2F36)))
    ops.append(op(circle(cx, cy - 0.02 * s, 0.13 * s), fill(0xFF37474F)))
    ops.append(op(circle(cx, cy - 0.02 * s, 0.08 * s), fill(0xFFFFCA28, alpha=0.85)))
    ops.append(op(circle(cx, cy + 0.16 * s, 0.045 * s), fill(0xFFFFF59D)))
    return ops, s, s


def enemy_artillery_barrage():
    s = 52.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.08 * s,), 0.14 * s, 0.58 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.6 * s, 0.4 * s, 6),
                  gradient_fill([0xFF5D4037, 0xFF2E1A16], cx, cy, 0.6 * s, 0.4 * s, "vertical")))
    ops.append(op(rrect(cx, cy - 0.16 * s, 0.5 * s, 0.16 * s, 3), fill(0xFF3E2723)))
    for dx in (-0.14 * s, 0.0, 0.14 * s):
        ops.append(op(rrect(cx + dx, cy - 0.24 * s, 0.1 * s, 0.22 * s, 2), fill(0xFF3E2723)))
    ops.append(op(circle(cx, cy + 0.02 * s, 0.05 * s), fill(0xFFE53935)))
    return ops, s, s


def enemy_attack_plane():
    return jet(0xFFB0BEC5, 0xFF78909C, 0xFF37474F, 0xFFFF5252, 0xFFFF7043)


def enemy_helicopter():
    """Apache/Black Hawk-style attack-helicopter gunship - mirrors
    `EnemySpriteFactory._paintHelicopter`: a tapered pointed-nose fuselage,
    chin gun turret, stepped tandem canopy, belly weapon-pylon pods, and an
    upswept tail stabilizer fin alongside the tail rotor."""
    s = 46.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.92 * s, 0.28 * s)]

    boom_pts = [
        (cx - 0.08 * s, cy - 0.09 * s),
        (cx - 0.48 * s, cy - 0.03 * s),
        (cx - 0.48 * s, cy + 0.04 * s),
        (cx - 0.08 * s, cy + 0.1 * s),
    ]
    ops.append(op(polygon(boom_pts), fill(0xFF33383C)))

    fin_pts = [
        (cx - 0.46 * s, cy - 0.02 * s),
        (cx - 0.58 * s, cy - 0.2 * s),
        (cx - 0.36 * s, cy - 0.04 * s),
    ]
    ops.append(op(polygon(fin_pts), fill(0xFF1A1C20)))

    ops.append(op(circle(cx - 0.5 * s, cy - 0.02 * s, 0.09 * s), stroke(0x99B0BEC5, 1.6)))

    body_pts = [
        (cx + 0.44 * s, cy),
        (cx + 0.2 * s, cy - 0.14 * s),
        (cx - 0.18 * s, cy - 0.15 * s),
        (cx - 0.2 * s, cy - 0.02 * s),
        (cx - 0.2 * s, cy + 0.1 * s),
        (cx - 0.1 * s, cy + 0.16 * s),
        (cx + 0.2 * s, cy + 0.14 * s),
    ]
    bx, by, bw, bh = bounds(body_pts)
    ops.append(op(polygon(body_pts), gradient_fill([0xFF5A6560, 0xFF20262A], bx, by, bw, bh, "vertical")))

    ops.append(op(rrect(cx - 0.08 * s, cy - 0.2 * s, 0.24 * s, 0.1 * s, 3), fill(0xFF1A1C20)))
    ops.append(op(circle(cx - 0.18 * s, cy - 0.19 * s, 0.035 * s), fill(0xFF0D0F10)))

    front_canopy = (cx + 0.22 * s, cy - 0.06 * s, 0.16 * s, 0.1 * s)
    rear_canopy = (cx + 0.02 * s, cy - 0.12 * s, 0.16 * s, 0.1 * s)
    for ccx, ccy, cw, ch in (rear_canopy, front_canopy):
        ops.append(op(rrect(ccx, ccy, cw, ch, 2), fill(0xFF11151A)))
        ops.append(op(rrect(ccx, ccy, cw * 0.86, ch * 0.72, 1), fill(0xFF37474F)))
    ops.append(op(
        rrect(front_canopy[0] - front_canopy[2] * 0.2, front_canopy[1] - 0.02 * s,
              front_canopy[2] * 0.3, front_canopy[3] * 0.4, 1),
        fill(0xFFFFFFFF, alpha=0.6),
    ))

    ops.append(op(circle(cx + 0.3 * s, cy + 0.08 * s, 0.06 * s), fill(0xFF1A1C20)))
    ops.append(op(circle(cx + 0.3 * s, cy + 0.08 * s, 0.035 * s), fill(0xFF37474F)))

    for dx in (-0.02 * s, 0.16 * s):
        pod_cx, pod_cy, pod_w, pod_h = cx + dx, cy + 0.16 * s, 0.14 * s, 0.08 * s
        ops.append(op(rrect(pod_cx, pod_cy, pod_w, pod_h, 2), fill(0xFF2B2F33)))
        ops.append(op(circle(pod_cx + pod_w / 2, pod_cy, pod_h * 0.28), fill(0xFF0D0F10)))

    for dy in (0.24 * s, 0.29 * s):
        ops.append(op(line_shape((cx - 0.14 * s, cy + dy), (cx + 0.28 * s, cy + dy)), stroke(0xFF1A1C20, 1.6)))

    ops.append(op(rrect(cx, cy - 0.24 * s, 0.06 * s, 0.14 * s, 2), fill(0xFF1A1C20)))
    return ops, s, s


def enemy_rocket_barrage():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.86 * s, 0.3 * s)]
    body = cx, cy + 0.1 * s
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6),
                  gradient_fill([0xFF5D4037, 0xFF2E1A16], body[0], body[1], 0.62 * s, 0.56 * s, "vertical")))
    ops.append(op(rrect(cx, cy - 0.22 * s, 0.5 * s, 0.3 * s, 4), fill(0xFF37474F)))
    for dx in (-0.16 * s, 0.0, 0.16 * s):
        ops.append(op(circle(cx + dx, cy - 0.22 * s, 0.06 * s), fill(0xFFE53935)))
    ops += wheel_grid(cx, cy, s, (-0.32 * s, 0.32 * s), (-0.06 * s, 0.32 * s), 0.14 * s, 0.22 * s, 2)
    return ops, s, s


def enemy_tank():
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.06 * s,), 0.13 * s, 0.6 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.58 * s, 0.4 * s, 6),
                  gradient_fill([0xFF6D4C41, 0xFF3E2723], cx, cy, 0.58 * s, 0.4 * s, "vertical")))
    turret = circle(cx, cy, 0.19 * s)
    ops.append(op(turret, gradient_fill([0xFF8D6E63, 0xFF3E2723], cx, cy, 0.38 * s, 0.38 * s, "horizontal")))
    ops.append(op(rrect(cx, cy - 0.28 * s, 0.09 * s, 0.34 * s, 2), fill(0xFF2B2F36)))
    ops.append(op(rrect(cx, cy + 0.02 * s, 0.1 * s, 0.04 * s, 2), fill(0xFFE53935)))
    ops.append(op(circle(cx, cy + 0.16 * s, 0.045 * s), fill(0xFFFFF59D)))
    return ops, s, s


# Flying-wing stealth bomber - one silhouette shared by both `ally_` and
# `enemy_` keys (team ownership shown by `TeamStripeMarkerComponent`
# instead of recoloring the model), mirroring
# `AllySpriteFactory._paintStealthBomber`/`EnemySpriteFactory._paintStealthBomber`.
def stealth_bomber():
    """Top-down B-2 style flying wing: a two-kink swept leading edge, the
    double-W sawtooth trailing edge, cockpit windows, intake slits, panel
    lines and a lighter spine. One silhouette shared by both `ally_` and
    `enemy_` keys (ownership is shown by the team ring/stripe overlays).
    Mirrors `paintStealthBomber` in
    `lib/core/rendering/util/paint_bomber.dart`."""
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.04 * s, cy + 0.07 * s, 0.9 * s, 0.5 * s, 0x2A000000)]
    right = [
        (cx, cy - 0.40 * s),
        (cx + 0.22 * s, cy - 0.16 * s),
        (cx + 0.50 * s, cy + 0.20 * s),
        (cx + 0.50 * s, cy + 0.27 * s),
        (cx + 0.36 * s, cy + 0.40 * s),
        (cx + 0.24 * s, cy + 0.32 * s),
        (cx + 0.12 * s, cy + 0.42 * s),
        (cx, cy + 0.30 * s),
    ]
    wing = polygon(right[:-1] + [(cx, cy + 0.30 * s)] + _mirror_x(right[1:-1], cx))
    ops.append(op(wing, gradient_fill([0xFF59606A, 0xFF2A2F36, 0xFF121417], cx, cy, 1.0 * s, 0.8 * s, "vertical")))
    ops.append(op(wing, stroke(0xFF0A0B0D, 1.0, alpha=0.9)))

    # Lighter spine along the centre line.
    spine = [
        (cx, cy - 0.38 * s),
        (cx + 0.07 * s, cy - 0.1 * s),
        (cx + 0.06 * s, cy + 0.26 * s),
        (cx, cy + 0.29 * s),
        (cx - 0.06 * s, cy + 0.26 * s),
        (cx - 0.07 * s, cy - 0.1 * s),
    ]
    ops.append(op(polygon(spine), fill(0xFF7B838E, alpha=0.26)))

    # Panel lines across each wing.
    for sx in (1, -1):
        ops.append(op(line_shape((cx + sx * 0.08 * s, cy - 0.08 * s), (cx + sx * 0.42 * s, cy + 0.22 * s)), stroke(0xFF000000, 0.7, alpha=0.35)))
        ops.append(op(line_shape((cx + sx * 0.1 * s, cy + 0.08 * s), (cx + sx * 0.3 * s, cy + 0.3 * s)), stroke(0xFF000000, 0.7, alpha=0.3)))

    # Intake slits and cockpit windows.
    for sx in (1, -1):
        ops.append(op(rrect(cx + sx * 0.1 * s, cy - 0.06 * s, 0.07 * s, 0.022 * s, 1), fill(0xFF050607)))
        ops.append(op(rrect(cx + sx * 0.035 * s, cy - 0.27 * s, 0.03 * s, 0.05 * s, 1), fill(0xFF1B2A38)))
        ops.append(op(rrect(cx + sx * 0.035 * s, cy - 0.285 * s, 0.014 * s, 0.02 * s, 0.5), fill(0xFF9BC4E2, alpha=0.7)))

    # Exhaust slots between the trailing-edge teeth.
    for sx in (1, -1):
        ops.append(op(rrect(cx + sx * 0.18 * s, cy + 0.35 * s, 0.07 * s, 0.02 * s, 1), fill(0xFF050607)))
    return ops, s, s


UNITS = {
    "ally_soldier": ally_soldier,
    "ally_tank": ally_tank,
    "ally_lightVehicle": ally_light_vehicle,
    "ally_aircraft": ally_aircraft,
    "ally_rocketBarrage": ally_rocket_barrage,
    "ally_antiTankSoldier": ally_anti_tank,
    "ally_antiAirSoldier": ally_anti_air,
    "ally_stealthBomber": stealth_bomber,
    "ally_drone": ally_drone,
    "enemy_soldier": lambda: enemy_infantry(False),
    "enemy_heavySoldier": lambda: enemy_infantry(True),
    "enemy_tank": enemy_tank,
    "enemy_helicopter": enemy_helicopter,
    "enemy_attackPlane": enemy_attack_plane,
    "enemy_artilleryBarrage": enemy_artillery_barrage,
    "enemy_rocketBarrage": enemy_rocket_barrage,
    "enemy_antiAirVehicle": enemy_anti_air_vehicle,
    "enemy_stealthBomber": stealth_bomber,
    "enemy_drone": enemy_drone,
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(SVG_OUT_DIR, exist_ok=True)
    for key, builder in UNITS.items():
        ops, w, h = builder()
        write_layer(ops, int(w), int(h), os.path.join(OUT_DIR, f"{key}.json"))
        write_svg(ops, int(w), int(h), os.path.join(SVG_OUT_DIR, f"{key}.svg"))


if __name__ == "__main__":
    main()
