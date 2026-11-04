% =========================================================
% PROJET : Simulation avec Algorithme d'Optimisation & Export CSV
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

base_power_active = 100; 
base_power_sleep  = 20;  
max_dynamic_power = 300; 

total_energy_history = zeros(1, T);
total_energy_before_opt = zeros(1, T); 

figure('Name', 'Simulation 5G : Avec Optimisation', 'Color', 'w');
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
    
    [~, serving_gNB_initial] = min(distances, [], 2);
    load_initial = zeros(num_gNB, 1);
    for j = 1:num_gNB
        load_initial(j) = sum(serving_gNB_initial == j);
    end
    energy_before = sum(base_power_active + (load_initial / num_UE) * max_dynamic_power * traffic_factor);
    total_energy_before_opt(t) = energy_before;
    
    serving_gNB_opt = serving_gNB_initial;
    load_opt = load_initial;
    antenna_state = ones(num_gNB, 1); 
    
    for j = 1:num_gNB
        if load_opt(j) > 0 && load_opt(j) <= 3 
            users_to_move = find(serving_gNB_opt == j);
            for u = users_to_move'
                [~, sorted_idx] = sort(distances(u, :));
                for k = 2:num_gNB
                    next_gNB = sorted_idx(k);
                    if load_opt(next_gNB) < 12 
                        serving_gNB_opt(u) = next_gNB;
                        load_opt(j) = load_opt(j) - 1;
                        load_opt(next_gNB) = load_opt(next_gNB) + 1;
                        break;
                    end
                end
            end
        end
        if load_opt(j) == 0
            antenna_state(j) = 0; 
        end
    end
    
    energy_after = 0;
    for j = 1:num_gNB
        if antenna_state(j) == 0
            energy_after = energy_after + base_power_sleep;
        else
            energy_after = energy_after + base_power_active + (load_opt(j) / num_UE) * max_dynamic_power * traffic_factor;
        end
    end
    total_energy_history(t) = energy_after;
    
    clf; hold on; grid on;
    xlim([0 area_size]); ylim([0 area_size]);
    title(sprintf('Étape %d/%d | Sans Opt: %.1fW | Avec Opt: %.1fW', t, T, energy_before, energy_after));
    
    for j = 1:num_gNB
        if antenna_state(j) == 1
            scatter(gNB_pos(j,1), gNB_pos(j,2), 150, 'r', '^', 'filled');
        else
            scatter(gNB_pos(j,1), gNB_pos(j,2), 150, 'b', '^', 'filled');
            text(gNB_pos(j,1)+20, gNB_pos(j,2), 'SLEEP', 'Color', 'b', 'FontWeight', 'bold');
        end
        
        users_j = UE_pos(serving_gNB_opt == j, :);
        if ~isempty(users_j)
            scatter(users_j(:,1), users_j(:,2), 40, colors(j,:), 'o', 'filled');
        end
    end
    for i = 1:num_UE
        j = serving_gNB_opt(i);
        plot([UE_pos(i,1), gNB_pos(j,1)], [UE_pos(i,2), gNB_pos(j,2)], 'k:', 'LineWidth', 0.3);
    end
    hold off; drawnow; pause(0.05);
end

% Graphique Comparatif
figure('Name', 'Impact de l''Optimisation', 'Color', 'w');
plot(1:T, total_energy_before_opt, 'r--', 'LineWidth', 2); hold on;
plot(1:T, total_energy_history, 'g-', 'LineWidth', 2);
grid on; xlabel('Temps (Étapes)'); ylabel('Consommation Totale (Watts)');
legend('Sans Optimisation', 'Avec Optimisation', 'Location', 'best');

% Exportation CSV
Time_Steps = (1:T)';
Energy_Sans_Opt = total_energy_before_opt';
Energy_Avec_Opt = total_energy_history';
Results_Table = table(Time_Steps, Energy_Sans_Opt, Energy_Avec_Opt);
writetable(Results_Table, 'resultats_green_5g.csv');
disp('✅ Fichier CSV exporté avec succès !');