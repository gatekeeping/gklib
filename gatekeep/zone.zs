// A Zone has four Gateways, one facing each cardinal direction.
class GK_Zone play
{
    GK_Dungeon dungeon;
    
     // location in template
    int templateX;
    int templateY;
    GK_Gateway templateGates[4];
    Vector2 templateCenter;
    
    // location in playfield
    int x;
    int y; 
    GK_Gateway gates[4];
    
    int face;
    bool placed;
    
    static GK_Zone create(GK_Dungeon d, int tx, int ty) {
        let p = new();
        p.dungeon = d;
        p.templateX = tx;
        p.templateY = ty;
        let zs = d.config.zoneSize;
        let h = zs / 2;
        p.templateCenter = (tx * zs + h, ty * zs + h);
        ++d.zoneCounter;
        return p;
    }
    
    GK_Gateway getGateway(int face) {
        let p = templateGates[face];
        if (p != null) return p;
        p = GK_Gateway.create(self, face);
        templateGates[face] = p;
        ++dungeon.gatewayCounter;
        return p;
    }
    
    void removeFromPlayfield() {
        placed = false;
        for (let i = 0; i < 4; i++) {
            let g = gates[i];
            if (!g) continue;
            g.placed = false;
            g.assigned = false;
        }
    }
}
