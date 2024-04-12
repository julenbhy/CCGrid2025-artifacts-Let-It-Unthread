use anyhow::Result;
use wasmtime::*;
use std::time::Instant;

const N_ITERS: u64 = 100000;

fn main() -> Result<()> {
    let engine = Engine::default();
    let module = Module::new(&engine, r#"(module (func (export "foo")))"#)?;
    let mut store = Store::new(&engine, ());
    let instance = Instance::new(&mut store, &module, &[])?;
    let foo = instance.get_func(&mut store, "foo").expect("export wasn't a function");

    let start_time = Instant::now();

    for _ in 0..N_ITERS {
        foo.call(&mut store, &[], &mut [])?;
    }
    
    let execution_time = start_time.elapsed();

    // Get the average time per call
    let execution_time = execution_time.as_nanos() as f64 / N_ITERS as f64;

    println!("{:?}ns", execution_time);

    Ok(())
}
