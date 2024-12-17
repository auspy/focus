"use client";

import { TestimonialCard } from "./testimonial-card";
import { useEffect, useRef } from "react";

const testimonials = [
  {
    name: "Helen",
    role: "Business Analyst",
    company: "",
    content:
      "I usually have to multitask and juggle lots of competing priorities at work, leading to overwhelm and reduced productivity. FocusMode has helped me focus on one task at a time, really helping me get my work done more efficiently.",
    imageUrl:
      "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Josh",
    role: "Managing Director",
    company: "",
    content:
      "I've always struggled with prioritizing and actually getting tasks done. I will admit this week, I have been the most productive that I have probably been in the last couple of months. Because this tool has helped me to actually just focus on one task at a time.",
    imageUrl:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Jack",
    role: "Software Engineer",
    company: "Amazon",
    content:
      "I've been using FocusMode everyday now. The yellow banner really helps me visualize time especially when I am time blind, really helps the ADHD brain. I have it always visible on my screen so I get reminded constantly of my current task.",
    imageUrl:
      "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Jane",
    role: "Marketing Associate",
    company: "Microsoft",
    content:
      "Y'all need to try this thing called FocusMode. It's crazy how simple it is but how much it helps me focus.",
    imageUrl:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Ng Wei",
    role: "Freelancer",
    company: "",
    content:
      "Using FocusMode I've been getting more productivity than I ever had been. Also managed to edit more photos in a single day than I ever had been able to as well.",
    imageUrl:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Mishka",
    role: "Entrepreneur",
    company: "",
    content:
      "It's crazy how well the tool fits into my workflow. I used to use a real timer on my desk with sticky notes for every task… I've completely replaced it. Anyone who wants to be the get the most of out their day, I definitely recommend FocusMode!",
    imageUrl:
      "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "John",
    role: "Hardware Engineer",
    company: "Apple",
    content:
      "I can't believe how much more productive I am with FocusMode. It's so simple and easy to use, and the floating timer really helps!",
    imageUrl:
      "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=faces",
  },
  {
    name: "Sarah",
    role: "Vice President",
    company: "Spotify",
    content:
      "FocusMode has been a game changer for me. I've been able to focus on one task at a time and get more done in a day than I ever have before.",
    imageUrl:
      "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150&h=150&fit=crop&crop=faces",
  },
];

function TestimonialSection() {
  const columnRefs = [useRef(null), useRef(null), useRef(null)];

  useEffect(() => {
    const resizeObserver = new ResizeObserver(() => {
      let minHeight = Infinity;
      let minColumn = 0;

      columnRefs.forEach((ref, index) => {
        if (ref.current && ref.current.offsetHeight < minHeight) {
          minHeight = ref.current.offsetHeight;
          minColumn = index;
        }
      });

      testimonials.forEach((_, index) => {
        const column = index % 3;
        if (column !== minColumn) {
          const element = document.getElementById(`testimonial-${index}`);
          if (element) {
            element.style.breakInside = "avoid";
            element.style.pageBreakInside = "avoid";
          }
        }
      });
    });

    columnRefs.forEach((ref) => {
      if (ref.current) {
        resizeObserver.observe(ref.current);
      }
    });

    return () => {
      resizeObserver.disconnect();
    };
  }, []);

  return (
    <section className="py-12 px-4 ">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-900 text-center mb-12">
          Why people love FocusMode ❤️
        </h2>
        <div className="columns-1 md:columns-2 lg:columns-3 gap-4">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              id={`testimonial-${index}`}
              ref={columnRefs[index % 3]}
            >
              <TestimonialCard {...testimonial} />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default TestimonialSection;
