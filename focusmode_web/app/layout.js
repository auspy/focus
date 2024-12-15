import { Inter } from "next/font/google";
import "./globals.css";
import Providers from "../components/Providers";
import { ClerkProvider } from "@clerk/nextjs";
import { Analytics } from "@vercel/analytics/react";
import Script from "next/script";
import { SpeedInsights } from "@vercel/speed-insights/next";
// import VizolvClient from "@/lib/VizolvClient";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Focus Mode | One Task at a Time",
  description:
    "A minimalist task timer designed for ADHD minds. Beat time blindness, stay focused, and get things done with a companion that understands your brain.",
  keywords:
    "ADHD, focus timer, task management, productivity, time blindness, ADHD app, focus mode, hyperactivity disorder",
  openGraph: {
    title: "Focus Mode | One Task at a Time",
    description:
      "A minimalist task timer designed for ADHD minds. Beat time blindness, stay focused, and get things done.",
    type: "website",
    url: "https://focusmo.de",
    // images: [
    //   {
    //     url: "/og-image.png",
    //     width: 1200,
    //     height: 630,
    //     alt: "FocusMode App Preview",
    //   },
    // ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Focus Mode | One Task at a Time",
    description:
      "A minimalist task timer designed for ADHD minds. Beat time blindness, stay focused, and get things done.",
    // images: ["/og-image.png"],
  },
};

export default function RootLayout({ children }) {
  const googleAnalytics = process.env.NEXT_PUBLIC_GOOGLE_ADD_ID;
  return (
    // <ClerkProvider>
    <html lang="en">
      {googleAnalytics && (
        <>
          <Script
            async
            src={`https://www.googletagmanager.com/gtag/js?id=${googleAnalytics}`}
          ></Script>
          <Script id="google-analytics">
            {`window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', '${googleAnalytics}');`}
          </Script>
        </>
      )}
      <body className={`${inter.className}  `}>
        <Providers>{children}</Providers>
        <Analytics />
        <SpeedInsights />
        {/* <VizolvClient /> */}
      </body>
    </html>
    // </ClerkProvider>
  );
}
