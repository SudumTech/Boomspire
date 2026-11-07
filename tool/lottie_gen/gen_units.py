"""Generates `assets/models/{ally,enemy}_<UnitKind.name>.json` Lottie files
that faithfully port the static shape geometry from
`lib/features/allies/presentation/ally_sprites.dart` and
`lib/features/enemies/presentation/enemy_sprites.dart`.

Each `*_unit` function below mirrors one Dart `_paint*` method line-for-line
(same `size`/`center` variables, same multipliers) so it can be diffed
against the source by eye. Run with:

    tool/lottie_gen/.venv/bin/python3 tool/lottie_gen/gen_units.py [--svg]
"""
import os
import sys

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

# Optional plain SVGs (`--svg`), NOT a runtime asset and not bundled: the game
# only loads the Lottie `.json` files above. They exist purely as source
# material to import into an external vector/rigging tool (e.g. Rive).
SVG_OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "models_svg")

# --- shared building blocks ------------------------------------------------


def shadow(cx, cy, w, h, argb=0x40000000):
    return op(ellipse(cx, cy, w, h), fill(argb))







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





def soldier_model(light, hull, dark, role, accent=0xFFFFB300):
    """Top-down infantryman, facing up: backpack, broad shoulders, arms
    bringing the weapon forward, and a helmet with a chin strap and night-
    vision mount. The legs are not part of the sprite - they are animated
    separately at runtime (`HumanLimbsComponent`). `role` picks the kit:
    `rifle`, `heavy` (armoured, cannon), `antitank` (rocket tube) or
    `antiair` (missile tube with sight). Mirrors `paintSoldierModel` in
    `lib/core/rendering/util/paint_soldier_model.dart`."""
    heavy = role == "heavy"
    s = 60.0 if heavy else 48.0
    cx = cy = s / 2
    k = 1.18 if heavy else 1.0
    skin = 0xFFC9A27C
    ops = [shadow(cx + 0.03 * s, cy + 0.05 * s, 0.56 * s, 0.46 * s, 0x33000000)]

    # Backpack behind the shoulders.
    ops.append(op(rrect(cx, cy + 0.13 * s, 0.27 * s * k, 0.22 * s, 3), gradient_fill([hull, dark], cx, cy, 0.27 * s, 0.22 * s, "vertical")))
    ops.append(op(rrect(cx, cy + 0.13 * s, 0.27 * s * k, 0.22 * s, 3), stroke(dark, 0.9, alpha=0.9)))
    ops.append(op(line_shape((cx - 0.05 * s, cy + 0.06 * s), (cx - 0.05 * s, cy + 0.2 * s)), stroke(dark, 1.0, alpha=0.8)))
    ops.append(op(line_shape((cx + 0.05 * s, cy + 0.06 * s), (cx + 0.05 * s, cy + 0.2 * s)), stroke(dark, 1.0, alpha=0.8)))

    # Launcher tube resting on the shoulder (specialists), drawn before the arms.
    if role == "antitank":
        ops.append(op(rrect(cx + 0.14 * s, cy - 0.12 * s, 0.075 * s, 0.7 * s, 2.5), gradient_fill([0xFF6A7078, 0xFF2C3036], cx, cy, 0.075 * s, 0.7 * s, "horizontal")))
        ops.append(op(polygon([(cx + 0.14 * s, cy - 0.5 * s), (cx + 0.175 * s, cy - 0.44 * s), (cx + 0.105 * s, cy - 0.44 * s)]), fill(accent)))
        ops.append(op(rrect(cx + 0.14 * s, cy + 0.22 * s, 0.1 * s, 0.05 * s, 1.5), fill(0xFF1A1C20)))
    if role == "antiair":
        ops.append(op(rrect(cx + 0.13 * s, cy - 0.1 * s, 0.07 * s, 0.62 * s, 2.5), gradient_fill([0xFFB9C4CD, 0xFF59646E], cx, cy, 0.07 * s, 0.62 * s, "horizontal")))
        ops.append(op(polygon([(cx + 0.13 * s, cy - 0.46 * s), (cx + 0.165 * s, cy - 0.4 * s), (cx + 0.095 * s, cy - 0.4 * s)]), fill(0xFF263238)))
        ops.append(op(rrect(cx + 0.205 * s, cy - 0.06 * s, 0.05 * s, 0.14 * s, 1.5), fill(0xFF1A1C20)))
        ops.append(op(circle(cx + 0.205 * s, cy - 0.1 * s, 0.022 * s), fill(accent)))

    # Shoulders.
    shoulders = ellipse(cx, cy - 0.0 * s, 0.56 * s * k, 0.24 * s * k)
    ops.append(op(shoulders, gradient_fill([light, hull, dark], cx, cy, 0.56 * s * k, 0.24 * s * k, "vertical")))
    ops.append(op(shoulders, stroke(dark, 1.0, alpha=0.9)))
    if heavy:
        ops.append(op(rrect(cx, cy + 0.0 * s, 0.26 * s, 0.2 * s, 4), fill(0xFF222A1B)))
        for sx in (-1, 1):
            ops.append(op(rrect(cx + sx * 0.25 * s * k, cy - 0.04 * s, 0.1 * s, 0.1 * s, 3), fill(0xFFB71C1C)))

    # Arms bringing the weapon forward, with gloved hands.
    for (x1, y1, x2, y2) in ((cx - 0.25 * s * k, cy - 0.01 * s, cx - 0.07 * s, cy - 0.25 * s),
                             (cx + 0.24 * s * k, cy - 0.01 * s, cx + 0.1 * s, cy - 0.15 * s)):
        ops.append(op(line_shape((x1, y1), (x2, y2)), stroke(hull, 0.085 * s, round_cap=True)))
        ops.append(op(line_shape((x1, y1), (x2, y2)), stroke(dark, 0.085 * s, alpha=0.25, round_cap=True)))
        ops.append(op(circle(x2, y2, 0.04 * s), fill(skin)))

    # Rifle / cannon along the right arm.
    if role in ("rifle", "heavy"):
        barrel_w = 0.075 * s if heavy else 0.05 * s
        ops.append(op(rrect(cx + 0.05 * s, cy - 0.31 * s, barrel_w, 0.34 * s, 1.5), fill(0xFF1C1F23)))
        ops.append(op(rrect(cx + 0.05 * s, cy - 0.16 * s, 0.075 * s, 0.2 * s, 2), gradient_fill([0xFF3C4147, 0xFF1A1C1F], cx, cy, 0.075 * s, 0.2 * s, "vertical")))
        ops.append(op(rrect(cx + 0.05 * s, cy - 0.46 * s, barrel_w * 1.5, 0.045 * s, 1), fill(0xFF0E1012)))
        ops.append(op(rrect(cx + 0.085 * s, cy - 0.1 * s, 0.035 * s, 0.08 * s, 1), fill(0xFF14171A)))
        if heavy:
            ops.append(op(rrect(cx + 0.22 * s, cy - 0.14 * s, 0.1 * s, 0.14 * s, 2), fill(0xFF3B4A2A)))

    # Helmet: rim, shell, chin strap, night-vision mount, glint.
    hr = 0.135 * s * k
    ops.append(op(circle(cx, cy - 0.04 * s, hr), fill(dark)))
    helmet = circle(cx, cy - 0.045 * s, hr * 0.9)
    ops.append(op(helmet, gradient_fill([light, hull], cx, cy, 2 * hr, 2 * hr, "diagonal")))
    ops.append(op(line_shape((cx - hr * 0.8, cy - 0.04 * s), (cx + hr * 0.8, cy - 0.04 * s)), stroke(dark, 0.9, alpha=0.7)))
    ops.append(op(rrect(cx, cy - 0.04 * s - hr * 0.92, hr * 0.5, hr * 0.28, 1), fill(0xFF14171A)))
    ops.append(op(circle(cx - hr * 0.3, cy - 0.04 * s - hr * 0.35, hr * 0.2), fill(0xFFFFFFFF, alpha=0.4)))
    return ops, s, s


def heli_model(light, hull, dark, rocket_tip):
    """Top-down attack helicopter, nose up (it turns with its heading): a
    tapered fuselage with tandem canopies, a chin gun, stub wings carrying
    rocket pods, a tail boom with stabilisers and a tail rotor. The main rotor
    is spun separately at runtime (`RotorComponent`) over the mast. Mirrors
    `paintHelicopterModel` in `lib/core/rendering/util/paint_helicopter_model.dart`."""
    s = 46.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.05 * s, cy + 0.08 * s, 0.7 * s, 0.82 * s, 0x2A000000)]

    # Tail boom, stabilisers, tail rotor.
    boom = [(cx - 0.045 * s, cy + 0.1 * s), (cx + 0.045 * s, cy + 0.1 * s), (cx + 0.025 * s, cy + 0.47 * s), (cx - 0.025 * s, cy + 0.47 * s)]
    ops.append(op(polygon(boom), gradient_fill([hull, dark], cx, cy, 0.09 * s, 0.37 * s, "horizontal")))
    ops.append(op(rrect(cx, cy + 0.41 * s, 0.3 * s, 0.05 * s, 1.5), fill(dark)))
    ops.append(op(rrect(cx, cy + 0.455 * s, 0.025 * s, 0.1 * s, 1), fill(0xFF14171A)))
    ops.append(op(circle(cx + 0.06 * s, cy + 0.46 * s, 0.06 * s), stroke(0xFFB0BEC5, 1.2, alpha=0.5)))

    # Stub wings with rocket pods and their tips.
    for sx in (-1, 1):
        wing = [(cx + sx * 0.09 * s, cy - 0.04 * s), (cx + sx * 0.36 * s, cy + 0.0 * s), (cx + sx * 0.36 * s, cy + 0.07 * s), (cx + sx * 0.09 * s, cy + 0.1 * s)]
        ops.append(op(polygon(wing), gradient_fill([light, hull], cx, cy, 0.27 * s, 0.14 * s, "vertical")))
        ops.append(op(polygon(wing), stroke(dark, 0.9, alpha=0.9)))
        ops.append(op(rrect(cx + sx * 0.3 * s, cy + 0.01 * s, 0.075 * s, 0.24 * s, 2.5), gradient_fill([0xFF4A4F55, 0xFF1F2327], cx, cy, 0.075 * s, 0.24 * s, "horizontal")))
        ops.append(op(circle(cx + sx * 0.3 * s, cy - 0.1 * s, 0.022 * s), fill(rocket_tip)))
        ops.append(op(circle(cx + sx * 0.3 * s, cy + 0.12 * s, 0.018 * s), fill(0xFF0E1012)))

    # Fuselage.
    right = [(cx, cy - 0.4 * s), (cx + 0.07 * s, cy - 0.3 * s), (cx + 0.115 * s, cy - 0.08 * s), (cx + 0.1 * s, cy + 0.12 * s), (cx + 0.045 * s, cy + 0.26 * s)]
    left = [(2 * cx - x, y) for (x, y) in reversed(right[1:])]
    body = polygon(right + left)
    ops.append(op(body, gradient_fill([dark, hull, light, hull, dark], cx, cy, 0.23 * s, 0.66 * s, "horizontal")))
    ops.append(op(body, stroke(dark, 1.0, alpha=0.9)))

    # Tandem canopies, intakes, exhaust.
    for (cyy, h) in ((cy - 0.23 * s, 0.12 * s), (cy - 0.07 * s, 0.14 * s)):
        ops.append(op(rrect(cx, cyy, 0.115 * s, h, 3), fill(0xFF11161B)))
        ops.append(op(rrect(cx, cyy, 0.095 * s, h * 0.8, 2.5), fill(0xFF2F4350)))
        ops.append(op(rrect(cx - 0.02 * s, cyy - h * 0.15, 0.03 * s, h * 0.35, 1), fill(0xFFFFFFFF, alpha=0.5)))
    for sx in (-1, 1):
        ops.append(op(rrect(cx + sx * 0.085 * s, cy + 0.1 * s, 0.04 * s, 0.1 * s, 1.5), fill(0xFF0E1012)))

    # Rotor mast and the chin gun with its barrel.
    ops.append(op(circle(cx, cy + 0.02 * s, 0.045 * s), fill(0xFF14171A)))
    ops.append(op(rrect(cx, cy - 0.42 * s, 0.022 * s, 0.1 * s, 1), fill(0xFF0E1012)))
    ops.append(op(circle(cx, cy - 0.35 * s, 0.035 * s), fill(0xFF1B1E22)))
    return ops, s, s


def ally_soldier():
    return soldier_model(0xFF8FA07C, 0xFF58693F, 0xFF2C3722, "rifle")


def ally_anti_tank():
    return soldier_model(0xFF8FA07C, 0xFF58693F, 0xFF2C3722, "antitank", accent=0xFFFF7043)


def ally_anti_air():
    return soldier_model(0xFF8FA07C, 0xFF58693F, 0xFF2C3722, "antiair", accent=0xFF29B6F6)


def enemy_infantry(heavy: bool):
    return soldier_model(0xFFA48A78, 0xFF6C5040, 0xFF33241B, "heavy" if heavy else "rifle")


def enemy_helicopter():
    return heli_model(0xFF8C9A86, 0xFF4F5D4A, 0xFF262E24, 0xFFFF7043)


def tank_model(light, hull, dark, track):
    """Top-down main battle tank (barrel up): long tracked sides with tread
    ticks, a wedge-fronted hull with a glacis plate and engine-deck grille,
    a rounded turret with smoke dischargers, a hatch, and a barrel with a
    bore evacuator and muzzle brake. Both sides use this design in their own
    paint (the team colour is the glowing marker, added at runtime). Mirrors
    `paintTankModel` in `lib/core/rendering/util/paint_tank_model.dart`."""
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.03 * s, cy + 0.05 * s, 0.8 * s, 0.9 * s, 0x2A000000)]

    # Tracks with tread ticks and a soft highlight.
    for sx in (-1, 1):
        x = cx + sx * 0.31 * s
        ops.append(op(rrect(x, cy, 0.2 * s, 0.9 * s, 3.5), fill(track)))
        for i in range(13):
            y = cy - 0.41 * s + i * 0.068 * s
            ops.append(op(line_shape((x - 0.085 * s, y), (x + 0.085 * s, y)), stroke(0xFF000000, 0.8, alpha=0.5)))
        ops.append(op(rrect(x - sx * 0.05 * s, cy, 0.03 * s, 0.84 * s, 1), fill(0xFFFFFFFF, alpha=0.1)))

    # Hull: wedge nose, straight flanks.
    hull_pts = [
        (cx - 0.12 * s, cy - 0.44 * s), (cx + 0.12 * s, cy - 0.44 * s),
        (cx + 0.22 * s, cy - 0.31 * s), (cx + 0.22 * s, cy + 0.4 * s),
        (cx - 0.22 * s, cy + 0.4 * s), (cx - 0.22 * s, cy - 0.31 * s),
    ]
    body = polygon(hull_pts)
    ops.append(op(body, gradient_fill([light, hull, dark], cx, cy, 0.44 * s, 0.84 * s, "vertical")))
    ops.append(op(body, stroke(dark, 1.0, alpha=0.9)))
    # Glacis highlight.
    ops.append(op(polygon([(cx - 0.12 * s, cy - 0.44 * s), (cx + 0.12 * s, cy - 0.44 * s), (cx + 0.2 * s, cy - 0.32 * s), (cx - 0.2 * s, cy - 0.32 * s)]), fill(0xFFFFFFFF, alpha=0.16)))
    # Engine deck grille.
    ops.append(op(rrect(cx, cy + 0.31 * s, 0.34 * s, 0.14 * s, 2), fill(dark, alpha=0.55)))
    for i in range(4):
        y = cy + 0.26 * s + i * 0.035 * s
        ops.append(op(line_shape((cx - 0.15 * s, y), (cx + 0.15 * s, y)), stroke(0xFF000000, 0.8, alpha=0.5)))

    # Barrel first (the turret overlaps its base): bore evacuator + muzzle brake.
    ops.append(op(rrect(cx, cy - 0.29 * s, 0.07 * s, 0.4 * s, 1.5), gradient_fill([0xFF4A4F55, 0xFF1D2125], cx, cy, 0.07 * s, 0.4 * s, "horizontal")))
    ops.append(op(rrect(cx, cy - 0.27 * s, 0.1 * s, 0.05 * s, 1.5), fill(0xFF2A2E33)))
    ops.append(op(rrect(cx, cy - 0.49 * s, 0.11 * s, 0.05 * s, 1), fill(0xFF14171A)))

    # Turret: bustle, rounded body, smoke dischargers, hatch.
    ops.append(op(rrect(cx, cy + 0.15 * s, 0.26 * s, 0.09 * s, 3), fill(dark)))
    turret = rrect(cx, cy - 0.01 * s, 0.38 * s, 0.34 * s, 0.13 * s)
    ops.append(op(turret, gradient_fill([light, hull], cx, cy, 0.38 * s, 0.34 * s, "diagonal")))
    ops.append(op(turret, stroke(dark, 1.0, alpha=0.9)))
    for sx in (-1, 1):
        for i in range(3):
            ops.append(op(rrect(cx + sx * 0.2 * s, cy - 0.07 * s + i * 0.045 * s, 0.035 * s, 0.03 * s, 0.8), fill(dark)))
    ops.append(op(circle(cx + 0.07 * s, cy + 0.04 * s, 0.05 * s), fill(dark)))
    ops.append(op(circle(cx + 0.07 * s, cy + 0.04 * s, 0.05 * s), stroke(light, 0.8, alpha=0.8)))
    ops.append(op(rrect(cx - 0.08 * s, cy - 0.1 * s, 0.05 * s, 0.025 * s, 0.6), fill(0xFF0E1417)))
    return ops, s, s


def artillery_model(light, hull, dark, track, accent):
    """Top-down rocket-artillery truck (launcher forward): a six-wheel chassis,
    a small cab at the front, and a raised launcher box on the rear deck with
    three rocket tubes and a hydraulic stabiliser. Mirrors
    `paintArtilleryModel` in `lib/core/rendering/util/paint_tank_model.dart`."""
    s = 52.0
    cx = cy = s / 2
    ops = [shadow(cx + 0.03 * s, cy + 0.05 * s, 0.75 * s, 0.9 * s, 0x2A000000)]

    # Three wheels per side.
    for sx in (-1, 1):
        for dy in (-0.28, 0.0, 0.28):
            ops.append(op(rrect(cx + sx * 0.31 * s, cy + dy * s, 0.15 * s, 0.22 * s, 3), fill(track)))
            ops.append(op(rrect(cx + sx * 0.31 * s, cy + dy * s, 0.07 * s, 0.14 * s, 2), fill(0xFF50555B)))

    # Chassis.
    chassis = rrect(cx, cy + 0.02 * s, 0.5 * s, 0.86 * s, 4)
    ops.append(op(chassis, gradient_fill([light, hull, dark], cx, cy, 0.5 * s, 0.86 * s, "vertical")))
    ops.append(op(chassis, stroke(dark, 1.0, alpha=0.9)))

    # Cab with windscreen.
    ops.append(op(rrect(cx, cy - 0.32 * s, 0.4 * s, 0.2 * s, 4), gradient_fill([light, hull], cx, cy, 0.4 * s, 0.2 * s, "vertical")))
    ops.append(op(rrect(cx, cy - 0.38 * s, 0.3 * s, 0.06 * s, 2), fill(0xFF14202B)))
    ops.append(op(rrect(cx - 0.06 * s, cy - 0.385 * s, 0.1 * s, 0.025 * s, 1), fill(0xFF9BC4E2, alpha=0.5)))

    # Launcher box with three rocket tubes.
    box = rrect(cx, cy + 0.12 * s, 0.42 * s, 0.4 * s, 4)
    ops.append(op(box, gradient_fill([hull, dark], cx, cy, 0.42 * s, 0.4 * s, "vertical")))
    ops.append(op(box, stroke(dark, 1.0, alpha=0.9)))
    for dx in (-0.13 * s, 0.0, 0.13 * s):
        ops.append(op(circle(cx + dx, cy + 0.1 * s, 0.065 * s), fill(0xFF101316)))
        ops.append(op(circle(cx + dx, cy + 0.1 * s, 0.065 * s), stroke(accent, 0.9, alpha=0.8)))
        ops.append(op(circle(cx + dx, cy + 0.1 * s, 0.03 * s), fill(0xFFE8ECEF)))
        ops.append(op(circle(cx + dx, cy + 0.1 * s, 0.015 * s), fill(accent)))
    # Stabiliser pads.
    for sx in (-1, 1):
        ops.append(op(rrect(cx + sx * 0.25 * s, cy + 0.36 * s, 0.07 * s, 0.07 * s, 1.5), fill(dark)))
    return ops, s, s


def ally_tank():
    return tank_model(0xFF8FA07C, 0xFF58693F, 0xFF2C3722, 0xFF1B1D20)


def enemy_tank():
    return tank_model(0xFFA48A78, 0xFF6C5040, 0xFF33241B, 0xFF1B1D20)


def ally_artillery_barrage():
    return artillery_model(0xFF8FA07C, 0xFF58693F, 0xFF2C3722, 0xFF1B1D20, 0xFFFFB300)


def enemy_artillery_barrage():
    return artillery_model(0xFFA48A78, 0xFF6C5040, 0xFF33241B, 0xFF1B1D20, 0xFFFFB300)


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


def enemy_attack_plane():
    return jet(0xFFB0BEC5, 0xFF78909C, 0xFF37474F, 0xFFFF5252, 0xFFFF7043)



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


# Flying-wing stealth bomber - one silhouette shared by both `ally_` and
# `enemy_` keys (team ownership shown by `TeamGlowMarkerComponent`
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
    "ally_artilleryBarrage": ally_artillery_barrage,
    "ally_antiAirVehicle": enemy_anti_air_vehicle,
    "ally_heavySoldier": lambda: enemy_infantry(True),
    "ally_helicopter": enemy_helicopter,
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
    export_svg = "--svg" in sys.argv
    os.makedirs(OUT_DIR, exist_ok=True)
    if export_svg:
        os.makedirs(SVG_OUT_DIR, exist_ok=True)
    for key, builder in UNITS.items():
        ops, w, h = builder()
        write_layer(ops, int(w), int(h), os.path.join(OUT_DIR, f"{key}.json"))
        if export_svg:
            write_svg(ops, int(w), int(h), os.path.join(SVG_OUT_DIR, f"{key}.svg"))


if __name__ == "__main__":
    main()
