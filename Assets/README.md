# NoglandWorld Assets Organization

## Folder Structure

### 📦 Models/
- **Buildings/** - Structures, walls, roofs, doors, windows
- **Props/** - Furniture, decorations, interactive objects
- **Terrain/** - Ground pieces, rocks, natural formations  
- **Characters/** - NPCs, enemies, character models

### 🎨 Materials/
- Shared materials (.tres files)
- PBR material setups
- Procedural materials

### 🖼️ Textures/
- Albedo maps
- Normal maps  
- Roughness/Metallic maps
- UI textures

### 🔊 Audio/
- Sound effects
- Background music
- Voice lines

### 🌍 Environments/
- Sky boxes
- Environment setups
- Lighting presets

## File Naming Convention

**Models:** `noun_descriptor.blend/gltf`
- `building_house_modern.gltf`
- `prop_chair_wooden.gltf`
- `terrain_rock_large.gltf`

**Materials:** `category_name_material.tres`
- `building_brick_red_material.tres`
- `prop_metal_rusty_material.tres`

**Scenes:** `PascalCase.tscn`
- `ModernHouse.tscn`
- `WoodenChair.tscn`

## Usage Tips

1. **Import 3D models** directly into appropriate subfolders
2. **Create scene instances** in `/Scenes/` that reference these assets
3. **Keep materials separate** for reusability across models
4. **Use consistent naming** for easy searching
