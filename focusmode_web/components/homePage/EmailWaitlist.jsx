"use client";

import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { z } from "zod";

const emailSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
});

export default function EmailWaitlist() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState("");
  const [loading, setLoading] = useState(false);
  const [validationError, setValidationError] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setValidationError("");
    setStatus("");

    try {
      // Validate email before making the request
      emailSchema.parse({ email });

      setLoading(true);
      const response = await fetch("/api/waitlist", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email }),
      });

      if (response.ok) {
        setStatus("success");
        setEmail("");
      } else {
        const data = await response.json();
        setErrorMessage(data?.error);
        setStatus("error");
      }
    } catch (error) {
      if (error instanceof z.ZodError) {
        setValidationError(error.errors[0].message);
      } else {
        setStatus("error");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <form
        onSubmit={handleSubmit}
        className="flex flex-col w-full max-w-md gap-2 "
      >
        <div className="flex gap-2">
          <Input
            type="email"
            value={email}
            onChange={(e) => {
              setEmail(e.target.value);
              setValidationError("");
              setStatus("");
            }}
            placeholder="Enter your email"
            className="flex-1 bg-white"
            disabled={loading}
            required
          />
          <Button
            type="submit"
            disabled={loading}
            className="whitespace-nowrap bg-primary hover:bg-accent"
          >
            {loading ? "Joining..." : "Join Waitlist"}
          </Button>
        </div>
        {validationError && (
          <p className="text-red-600 text-sm">{validationError}</p>
        )}
        {status === "success" && (
          <p className="text-green-600 text-sm">
            Thanks for joining the waitlist! Check your email for confirmation.
          </p>
        )}
        {status === "exists" && (
          <p className="text-blue-600 text-sm">
            You're already on the waitlist!
          </p>
        )}
        {status === "error" && (
          <p className="text-red-600 text-sm">
            {errorMessage || "Something went wrong. Please try again."}
          </p>
        )}
      </form>
      <p className="text-xs opacity-60 mt-2">
        Coming soon for macOS, Windows & Linux
      </p>
    </>
  );
}
