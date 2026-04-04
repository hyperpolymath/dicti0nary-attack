#![no_main]
use libfuzzer_sys::fuzz_target;
use dicti0nary_attack_generators::{
    LeetspeakGenerator, PatternGenerator, PhoneticGenerator, RandomGenerator,
};
use dicti0nary_attack_core::PasswordGenerator;

fuzz_target!(|data: &[u8]| {
    // Fuzz password generation with arbitrary input
    if let Ok(input) = std::str::from_utf8(data) {
        if input.is_empty() || input.len() > 100 {
            return;
        }

        // Test leetspeak generator
        let leetspeak = LeetspeakGenerator::new();
        let _ = leetspeak.generate(input, 10);

        // Test pattern generator
        let pattern = PatternGenerator::new();
        let _ = pattern.generate(input, 10);

        // Test phonetic generator
        let phonetic = PhoneticGenerator::new();
        let _ = phonetic.generate(input, 10);

        // Test random generator with seed from input
        if data.len() >= 4 {
            let random = RandomGenerator::new();
            let _ = random.generate("", 10);
        }
    }
});
