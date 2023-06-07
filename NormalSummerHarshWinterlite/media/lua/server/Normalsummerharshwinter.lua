Events.OnInitSeasons.Add( 
  function(_season) 
    _season:init(
        38, --sunlight hours
        25, --max temp default 25
        -20, --min temp default 0
        7, --temp diff default 7
        _season:getSeasonLag(), --31
        _season:getHighNoon(),  --12.5
        _season:getSeedA(),     --64
        _season:getSeedB(),     --128
        _season:getSeedC()		--255
	);                          
  end
);