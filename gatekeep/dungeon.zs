// A Dungeon has a Template and a Playfield, each containing a grid of Zones.
class GK_Dungeon play
{
    bool isReady;
    bool isInvalid;

    transient GK_LevelInit levelInit; // need this for static portals, moving vertices.
    
    GK_Config config;
    GK_Template template;
    GK_Playfield playfield;
    
    int lastLineId;
    
    int portalCounter;
    int zoneCounter;
    int gatewayCounter;
    int linkedGatewayCounter;
    int placedZoneCounter;
    
    static GK_Dungeon create(GK_LevelInit li, GK_Config config) {
        let p = new();
        
        p.levelInit = li;
        p.config = config;
        p.lastLineId = config.firstLineId - 1;
        
        console.printf("GK: Generating dungeon");
        
        p.template = GK_Template.create(p);
        
        console.printf("GK: Found %i portals in %i gateways",
            p.portalCounter, p.gatewayCounter);
        
        let tries = config.maxTries;
        
        do p.playfield = GK_Playfield.create(p);
        until (p.playfield.validate() || --tries < 0);
        
        if (tries < 0) {
            console.printf("GK: Failed to place at least %i of %i zones!",
                config.minZones, p.zoneCounter);
            p.isInvalid = true;
            return p;
        }
        
        p.playfield.finalize();
        
        console.printf("GK: Placed %i of %i zones after %i attempts",
            p.placedZoneCounter, p.zoneCounter, config.maxTries - tries + 1);
        
        console.printf("GK: Done generating dungeon");
        return p;
    }
    
    void rehydrate(GK_LevelInit li) {
        console.printf("GK: Rehydrating dungeon...");
        levelInit = li;
        lastLineId = config.firstLineId - 1;
        playfield.finalize();
        console.printf("GK: Done rehydrating dungeon");
        return;
    }
            
    int createLineId(int lineIndex) {
        let id = lastLineId++;
        levelInit._addLineId(lineIndex, id);
        return id;
    }
}
