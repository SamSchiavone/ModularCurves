// Usage: ls input_data | parallel --timeout 600 magma -b label:={1} GetModelLMFDB.m
// where input_data is a folder containing one file for each label, consisting of the generators as a comma-separated list of integers

System("mkdir -p ../output_data");
SetColumns(0);
AttachSpec("ModCrv.spec");
SetVerbose("ModularCurves", 1);

level := StringToInteger(Split(label, ".")[1]);
input := Read("../input_data/" * label);
input_lines := Split(input, "\n");
is_cover := false;
if IsEmpty(input_lines) then
    assert level eq 1;
    PG := Gamma0(1);
else
    gens := [StringToInteger(x) : x in Split(input_lines[1], ",")];
    coverings := input_lines[2..#input_lines];
    genera := [StringToInteger(Split(cover, ".")[3]) : cover in coverings];
    if not IsEmpty(genera) then
	_, idx := Maximum(genera);
	X_cov<[x]>, fs_cov, E4_cov, E6_cov, K_cov := LMFDBReadModel("output_data/" * coverings[idx]);
	is_cover := true;
    end if;
    // Should be a list of 2x2 matrices, so number of elements divisible by 4.
    assert #gens mod 4 eq 0;
    gens := [gens[4*(i-1)+1..4*i] : i in [1..#gens div 4]];
    G := sub<GL(2, Integers(level)) | gens>;
    G := GetRealConjugate(G);
    PG := PSL2Subgroup(G);
end if;
// This code only works for groups that are of real type
assert IsOfRealType(PG);
// This code only works for groups of genus at least 2
// assert Genus(PG) ge 2;
if Genus(PG) ge 2 then
    X<[x]>, fs, type, K := ModularCurve(PG);
    LogCanonical := false;
else
    type := "hyperelliptic";
end if;
if type eq "hyperelliptic" then
    vprintf ModularCurves, 1:
	"Curve is hyperelliptic, finding a log-canonical model for the j-map...\n";
    X<[x]>, fs, K := CanonicalRing(PG);
    LogCanonical := true;
end if;
// We do that, otherwise Magma gets upset...
if (not is_cover) then
    X_cov := X;
    fs_cov := fs;
    E4_cov := fs[1];
    E6_cov := fs[1];
end if;
if is_cover then
    // !! TODO - if K != K_cov has to take it into account
    cov_map := CoveringMap(X_cov, X, fs_cov, fs);
    E4, E6, j := JMap(cov_map, E4_cov, E6_cov);
else
    E4, E6, j := JMap(PG, X, fs, K
		  : LogCanonical := LogCanonical);
end if;
LMFDBWriteModel(X, fs, E4, E6, "../output_data/" * label);

exit;
