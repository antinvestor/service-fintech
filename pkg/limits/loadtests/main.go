// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//go:build loadtest

// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Binary limits-loadtest exercises the limits service Reserve+Commit+Release
// path at configurable throughput using the vegeta attack framework.
//
// Build:
//
//	go build -tags=loadtest -o limits-loadtest ./pkg/limits/loadtests/
//
// Run:
//
//	./limits-loadtest --target=https://limits.staging.internal --rps=1000 --duration=10m
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	vegeta "github.com/tsenart/vegeta/v12/lib"
)

func main() {
	target := flag.String("target", "", "limits service base URL, e.g. https://limits.staging.internal (required)")
	rps := flag.Int("rps", 1000, "target requests per second")
	duration := flag.Duration("duration", 10*time.Minute, "attack duration")
	output := flag.String("output", "loadtest-results.json", "path for JSON metrics output")
	subjects := flag.Int(
		"subjects",
		1000,
		"number of distinct subject IDs to rotate through (avoid advisory-lock hot spots)",
	)
	flag.Parse()

	if *target == "" {
		log.Fatal("--target is required. Example: --target=https://limits.staging.internal")
	}

	log.Printf("limits load test: target=%s rps=%d duration=%v subjects=%d output=%s",
		*target, *rps, *duration, *subjects, *output)
	log.Printf("capacity targets: p99 Reserve+Commit < 50ms, success rate > 99.9%%")

	rate := vegeta.Rate{Freq: *rps, Per: time.Second}
	targeter := makeTargeter(*target, *subjects)
	attacker := vegeta.NewAttacker()

	var metrics vegeta.Metrics
	log.Printf("starting attack …")
	for res := range attacker.Attack(targeter, rate, *duration, "limits") {
		metrics.Add(res)
	}
	metrics.Close()

	fmt.Printf("\n=== Limits Load Test Results ===\n")
	fmt.Printf("requests    : %d\n", metrics.Requests)
	fmt.Printf("rate        : %.2f req/s\n", metrics.Rate)
	fmt.Printf("throughput  : %.2f req/s\n", metrics.Throughput)
	fmt.Printf("p50 latency : %v\n", metrics.Latencies.P50)
	fmt.Printf("p95 latency : %v\n", metrics.Latencies.P95)
	fmt.Printf("p99 latency : %v\n", metrics.Latencies.P99)
	fmt.Printf("max latency : %v\n", metrics.Latencies.Max)
	fmt.Printf("success rate: %.4f%%\n", metrics.Success*100)
	fmt.Printf("errors      : %d\n", metrics.Errors)

	// Emit capacity pass/fail signals.
	const p99TargetMs = 50
	p99ms := metrics.Latencies.P99.Milliseconds()
	if p99ms > p99TargetMs {
		fmt.Printf("\n[FAIL] p99 latency %dms exceeds target of %dms\n", p99ms, p99TargetMs)
	} else {
		fmt.Printf("\n[PASS] p99 latency %dms is within target of %dms\n", p99ms, p99TargetMs)
	}
	const successTarget = 0.999
	if metrics.Success < successTarget {
		fmt.Printf("[FAIL] success rate %.4f%% is below target %.1f%%\n",
			metrics.Success*100, successTarget*100)
	} else {
		fmt.Printf("[PASS] success rate %.4f%% meets target %.1f%%\n",
			metrics.Success*100, successTarget*100)
	}

	f, err := os.Create(*output)
	if err != nil {
		log.Fatalf("failed to create output file %s: %v", *output, err)
	}
	defer f.Close()
	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	if err := enc.Encode(&metrics); err != nil {
		log.Fatalf("failed to write metrics JSON: %v", err)
	}
	log.Printf("results written to %s", *output)
}
