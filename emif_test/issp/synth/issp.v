// issp.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module issp (
		output wire [2:0]   source, // sources.source
		input  wire [351:0] probe   //  probes.probe
	);

	altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (352),
		.source_width            (3),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
	) in_system_sources_probes_0 (
		.source     (source), //  output,    width = 3, sources.source
		.probe      (probe),  //   input,  width = 352,  probes.probe
		.source_ena (1'b1)    // (terminated),                       
	);

endmodule
