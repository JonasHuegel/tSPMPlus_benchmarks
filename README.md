# tSPM+ benchmarks 
This repository stores the benchmarks that were used to measure the performance of the tSPM+ algorithm ((C++ library) [https://github.com/JonasHuegel/tspm_cpp_backend] (R package)[https://github.com/JonasHuegel/tSPMPlus_R] )for the publication.
We performed 2 different benchmarks, one where we compared the performance with tSPM on real world data (we cannont provide access to this data to its sensitive nature), and one benchmark to measure the possible performance.
For the second benchmark we used the [`syntheticmass 100k-covid data set`](https://synthea.mitre.org/downloads) synthetic data set [1, 2] from [SyntheaTM](https://synthetichealth.github.io/synthea/)
Since the file is 500MB large it is not included in the repository and should be download in the `data/syntheticData/` and extracted there.


References:
[1] Jason Walonoski, Mark Kramer, Joseph Nichols, Andre Quina, Chris Moesel, Dylan Hall, Carlton Duffett, Kudakwashe Dube, Thomas Gallagher, Scott McLachlan, Synthea: An approach, method, and software mechanism for generating synthetic patients and the synthetic electronic health care record, Journal of the American Medical Informatics Association, Volume 25, Issue 3, March 2018, Pages 230–238, https://doi.org/10.1093/jamia/ocx079

[2] Walonoski J, Klaus S, Granger E, Hall D, Gregorowicz A, Neyarapally G, Watson A, Eastman J. Synthea™ Novel coronavirus (COVID-19) model and synthetic data set. Intelligence-Based Medicine. 2020 Nov;1:100007. https://doi.org/10.1016/j.ibmed.2020.100007 