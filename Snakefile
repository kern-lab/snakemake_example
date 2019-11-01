import msprime
import tskit


mu = [0.001, 0.002, 0.003]
rhos = [ 0.001, 0.002, 0.006]

rule all:
	input: expand("{m}_{r}.trees", m=mu, r=rhos), expand("{m}_{r}.trees.vcf", m=mu, r=rhos)

rule simulation:
	output: "{m}_{r}.trees"
	run:
		ts = msprime.simulate(10, mutation_rate=float(wildcards.m), recombination_rate=float(wildcards.r),length=1e3)
		ts.dump(output)

rule make_vcf:
	output: "{m}_{r}.trees.vcf"
	input:  rules.simulation.output
	run:
		ts = tskit.load(input)
		fh = open(str(output),"w")
		ts.write_vcf(fh)

rule clean:
	shell: "rm *.trees *.vcf"
