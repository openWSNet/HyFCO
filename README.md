# HyFCO

#Source code of the paper entitled "A Hybrid Memetic Framework for Coverage Optimization in Wireless Sensor Networks"

C. P. Chen et al., "A Hybrid Memetic Framework for Coverage Optimization in Wireless Sensor Networks," in IEEE Transactions on Cybernetics, vol. 45, no. 10, pp. 2309-2322, Oct. 2015.

One of the critical concerns in wireless sensor networks (WSNs) is the continuous maintenance of sensing coverage. Many particular applications, such as battlefield intrusion detection and object tracking, require a full-coverage at any time, which is typically resolved by adding redundant sensor nodes. With abundant energy, previous studies suggested that the network lifetime can be maximized while maintaining full coverage through organizing sensor nodes into a maximum number of disjoint sets and alternately turning them on. Since the power of sensor nodes is unevenly consumed over time, and early failure of sensor nodes leads to coverage loss, WSNs require dynamic coverage maintenance. Thus, the task of permanently sustaining full coverage is particularly formulated as a hybrid of disjoint set covers and dynamic-coverage-maintenance problems, and both have been proven to be nondeterministic polynomial-complete. In this paper, a hybrid memetic framework for coverage optimization (Hy-MFCO) is presented to cope with the hybrid problem using two major components: 1) a memetic algorithm (MA)-based scheduling strategy and 2) a heuristic recursive algorithm (HRA). First, the MA-based scheduling strategy adopts a dynamic chromosome structure to create disjoint sets, and then the HRA is utilized to compensate the loss of coverage by awaking some of the hibernated nodes in local regions when a disjoint set fails to maintain full coverage. The results obtained from real-world experiments using a WSN test-bed and computer simulations indicate that the proposed Hy-MFCO is able to maximize sensing coverage while achieving energy efficiency at the same time. Moreover, the results also show that the Hy-MFCO significantly outperforms the existing methods with respect to coverage preservation and energy efficiency.


note:
1) perform main.m (main loop)
2) more than 5,000 test cases are packaged into "experimental_cases.zip," before you run main.m please unpack them in the same folder of main.m

paper link: http://ieeexplore.ieee.org/document/6982222/
