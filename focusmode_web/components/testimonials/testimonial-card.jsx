import Image from "next/image";
import { Star } from "lucide-react";

export function TestimonialCard({ name, role, company, content, imageUrl }) {
  return (
    <div className="bg-white rounded-lg p-6 break-inside-avoid mb-4 shadow-md">
      <div className="flex items-center mb-4">
        <Image
          src={imageUrl}
          alt={name}
          width={48}
          height={48}
          className="rounded-full mr-4"
        />
        <div>
          <h3 className="font-semibold text-gray-900">{name}</h3>
          <p className="text-sm text-gray-600">
            {role} at {company}
          </p>
        </div>
      </div>
      <div className="flex mb-4">
        {[...Array(5)].map((_, i) => (
          <Star key={i} className="w-5 h-5 text-yellow-400 fill-current" />
        ))}
      </div>
      <p className="text-gray-700">{content}</p>
    </div>
  );
}
