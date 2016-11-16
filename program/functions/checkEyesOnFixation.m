function detected = checkEyesOnFixation(x, y, screen_dimensions, fix_aoi_radius)

detected = 2;
if (x - screen_dimensions(2, 1))^2 + (y - screen_dimensions(2, 2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end
