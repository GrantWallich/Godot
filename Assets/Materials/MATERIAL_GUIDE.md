# 🎨 Godot Material System Guide

## Two Main Types

### 📱 StandardMaterial3D (Simple)
**Best for:** Basic materials, learning, rapid prototyping

**Properties you can set:**
```gdscript
albedo_color = Color(1, 0, 0, 1)     # Base color
albedo_texture = "texture.png"       # Diffuse map
metallic = 0.5                       # How metal-like (0-1)
roughness = 0.3                      # Surface roughness (0-1)
normal_texture = "normal.png"        # Bump mapping
emission_enabled = true              # Glow effect
emission = Color(1, 1, 0, 1)        # Glow color
emission_energy = 2.0                # Glow intensity
```

### 🎛️ ShaderMaterial + VisualShader (Node-Based)
**Best for:** Advanced effects, procedural materials, animations

**Visual Node Editor Features:**
- **Noise nodes** - Procedural textures
- **Math nodes** - Complex calculations  
- **Time nodes** - Animated effects
- **UV manipulation** - Scrolling, warping
- **Custom inputs** - Exposed parameters

## 🔧 How to Create Materials

### Method 1: In Godot Editor
1. **Create new resource** → StandardMaterial3D or ShaderMaterial
2. **Edit in Inspector** → Adjust properties
3. **Save as .tres** → Reusable across models

### Method 2: Visual Shader Editor
1. **Create ShaderMaterial**
2. **New VisualShader** → Opens node editor
3. **Drag nodes** → Connect with lines
4. **Expose parameters** → Make them adjustable

## 🎯 When to Use Which

### Use StandardMaterial3D for:
- ✅ Simple textures with basic lighting
- ✅ Quick prototyping
- ✅ PBR materials (albedo + normal + roughness)
- ✅ Basic emission effects

### Use VisualShader for:
- ✅ Animated water/lava effects
- ✅ Procedural patterns (no texture files needed)
- ✅ Complex lighting effects
- ✅ Dissolve/fade effects
- ✅ Stylized/cartoon materials

## 🚀 Advanced Examples

### Animated Glow Material
```
[Time] → [Sine] → [Multiply] → [Emission Energy]
```

### Scrolling Texture
```
[Time] → [UV] → [Add] → [Texture Sample]
```

### Procedural Brick Pattern
```
[UV] → [Noise] → [ColorRamp] → [Albedo]
```

## 💡 Pro Tips

1. **Start with StandardMaterial3D** - easier to learn
2. **Use VisualShader** when you need procedural/animated effects
3. **Save materials as .tres** files for reusability
4. **Name materials descriptively** (e.g., `metal_rusty_animated.tres`)
5. **Organize by type** in your Assets/Materials/ folder

## 🎮 For Your NoglandWorld

### Recommended Setup:
```
Assets/Materials/
├── Basic/           # StandardMaterial3D files
│   ├── metal_clean.tres
│   ├── concrete_rough.tres
│   └── wood_polished.tres
└── Advanced/        # ShaderMaterial files
	├── water_animated.tres
	├── hologram_glow.tres
	└── force_field.tres
```
