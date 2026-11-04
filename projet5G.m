% =========================================================
% PROJET : Simulation de base (Sans Optimisation)
% =========================================================
clc; clear; close all;

num_gNB = 8;        
num_UE = 60;        
area_size = 1000;   
T = 100;            
speed = 10;         

rng(42); 
gNB_pos = area_size * rand(num_gNB, 2);
UE_pos = area_size * rand(num_UE, 2);

base_power = 100; 
max_dynamic_power = 300; 
total_energy_history = zeros(1, T);

figure('Name', 'Simulation 5G : Sans Optimisation', 'Color', 'w');
colors = lines(num_gNB); 

for t = 1:T
    traffic_factor = 0.65 + 0.35 * sin(2 * pi * t / T); 
    
    crowd_center_x = (area_size/2) + (area_size/3) * cos(2 * pi * t / T);
    crowd_center_y = (area_size/2) + (area_size/3) * sin(2 * pi * t / T);
    
    for u = 1:num_UE
        dx = (crowd_center_x - UE_pos(u,1)) * 0.05 + speed * randn();
        dy = (crowd_center_y - UE_pos(u,2)) * 0.05 + speed * randn();
        UE_pos(u,:) = UE_pos(u,:) + [dx, dy];
    end
    UE_pos = max(min(UE_pos, area_size), 0);
    
    distances = zeros(num_UE, num_gNB);
    for i = 1:num_UE
        for j = 1:num_gNB
            distances(i,j) = norm(UE_pos(i,:) - gNB_pos(j,:));
        end
    end
    
    [~, serving_gNB] = min(distances, [], 2);
    load_per_gNB = zeros(num_gNB, 1);
    for j = 1:num_gNB
        load_per_gNB(j) = sum(serving_gNB == j);
    end
    
    energy_consumption = base_power + (load_per_gNB / num_UE) * max_dynamic_power * traffic_factor;
    total_energy_history(t) = sum(energy_consumption);
    
    clf; hold on; grid on;
    xlim([0 area_size]); ylim([0 area_size]);
    title(sprintf('Étape %d/%d | Énergie Sans Opt: %.1f W', t, T, total_energy_history(t)));
    
    scatter(gNB_pos(:,1), gNB_pos(:,2), 150, 'r', '^', 'filled');
    for j = 1:num_gNB
        users_j = UE_pos(serving_gNB == j, :);
        if ~isempty(users_j)
            scatter(users_j(:,1), users_j(:,2), 40, colors(j,:), 'o', 'filled');
        end
    end
    for i = 1:num_UE
        j = serving_gNB(i);
        plot([UE_pos(i,1), gNB_pos(j,1)], [UE_pos(i,2), gNB_pos(j,2)], 'k:', 'LineWidth', 0.3);
    end
    hold off; drawnow; pause(0.05);
end
disp('Simulation de base terminée.');