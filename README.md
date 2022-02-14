# Optimal-PMU-placement-with-conventional-measurements.
The monitoring of power grids is an important diagnostic task. This is effectively achieved by the deployment of Phasor Measurement Units (PMUs). PMUs have gained more popularity because of their ability to accurately measure bus voltage and branch current phasors with respect to a Global Positioning System (GPS) clock every few microseconds. Placing PMUs at all locations in a power system network is not economically feasible due to their cost. Therefore, it is necessary to properly distribute PMUs in order to obtain a good estimation of power system states. This problem is known as an optimal PMU placement (OPP) problem. The preliminary objective of an OPP problem is to find strategic locations for PMU placement such that:

• The system is completely observable and
• The solution is economically viable.
When considering the conventional measurements, the optimal placement of PMUs can be formulated as a problem of integer linear programming.

                                                             minimize Σ Xk
                                           subject to : 𝑻𝒄𝒐𝒏*𝑷* 𝑻pmu*𝑿 ≥  𝒃𝒄𝒐𝒏 
                                                           X= [𝑥1 𝑥2 …𝑥𝑁]𝑇
                                                           Xk ∈ {0,1} : PMU placement variable  
