import { CalendarIcon, FileTextIcon } from "@radix-ui/react-icons";
import { BentoCard, BentoGrid } from "@/components/magicui/bento-grid";

const files = [
  {
    name: "bitcoin.pdf",
    body: "Bitcoin is a cryptocurrency invented in 2008 by an unknown person or group of people using the name Satoshi Nakamoto.",
  },
  {
    name: "finances.xlsx",
    body: "A spreadsheet or worksheet is a file made of rows and columns that help sort data, arrange data easily, and calculate numerical data.",
  },
  {
    name: "logo.svg",
    body: "Scalable Vector Graphics is an Extensible Markup Language-based vector image format for two-dimensional graphics with support for interactivity and animation.",
  },
  {
    name: "keys.gpg",
    body: "GPG keys are used to encrypt and decrypt email, files, directories, and whole disk partitions and to authenticate messages.",
  },
  {
    name: "seed.txt",
    body: "A seed phrase, seed recovery phrase or backup seed phrase is a list of words which store all the information needed to recover Bitcoin funds on-chain.",
  },
];

const features = [
  {
    Icon: FileTextIcon,
    name: "Save your files",
    description: "We automatically save your files as you type.",
    href: "#",
    background: (
      <video
        src="/autoscroll.mp4"
        className="absolute top-0 max-h-1/2"
        autoPlay
        loop
        muted
      />
    ),
    cta: "Learn more",
    className: "col-span-3 lg:col-span-1",
  },
  {
    Icon: CalendarIcon,
    name: "Notifications",
    description: "Get notified when something happens.",
    href: "#",
    background: <img className="absolute -right-20 -top-20 opacity-60" />,
    cta: "Learn more",
    className: "col-span-3 lg:col-span-2",
  },
  {
    Icon: FileTextIcon,
    name: "Integrations",
    description: "Supports 100+ integrations and counting.",
    href: "#",
    background: <img className="absolute -right-20 -top-20 opacity-60" />,
    cta: "Learn more",
    className: "col-span-3 lg:col-span-2",
  },
  {
    Icon: CalendarIcon,
    name: "Calendar",
    description: "Use the calendar to filter your files by date.",
    className: "col-span-3 lg:col-span-1",
    href: "#",
    background: <img className="absolute -right-20 -top-20 opacity-60" />,
    cta: "Learn more",
  },
];

export default function FeatureGrid() {
  return (
    <BentoGrid className="wrapper py-20">
      {features.map((feature, idx) => (
        <BentoCard key={idx} {...feature} />
      ))}
    </BentoGrid>
  );
}
