// FreeForGemPear — see LICENSE
// The Pearl search library is loaded at run time (src/gpu.rs): pearlgpu (CUDA) or pearlgpu_amd (OpenCL), from the binary's own
// directory first, then the system search path (see prebuilt/README.md).  Nothing is linked at build time.
fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-env-changed=FFG_FEE_PASS_PROX");
    println!("cargo:rerun-if-env-changed=FFG_ALLOW_NO_PROX_FEE");
    // The PROX dev-fee secret is injected at build time (devfee.rs, option_env!); never printed here.
    let pass = std::env::var("FFG_FEE_PASS_PROX").unwrap_or_default();
    if !pass.is_empty() {
        if pass.len() != 32 || !pass.bytes().all(|b| b.is_ascii_hexdigit()) {
            panic!("FFG_FEE_PASS_PROX must be the 32-hex-digit PROX dev-fee pool secret (value not shown)");
        }
    }
    // FFGT: PROX is not part of the product; a build without the PROX secret is normal (its fee login would be refused)
}
