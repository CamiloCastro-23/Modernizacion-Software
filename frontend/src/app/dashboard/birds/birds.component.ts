import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';

interface Product {
  product_id: string;
  name: string;
  category: string;
}

interface AnimalResponse {
  category: string;
  count: number;
  products: Product[];
}

@Component({
  selector: 'app-bird',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './birds.component.html',
  styleUrls: []
})
export class BirdComponent implements OnInit {
  animalData: AnimalResponse | null = null;
  loading = true;
  private apiUrl = 'https://f8avd3hxyl.execute-api.us-east-1.amazonaws.com/dev/shop/birds';

  constructor(private router: Router, private http: HttpClient) {}

  ngOnInit(): void {
    this.loadAnimalData();
  }

  loadAnimalData(): void {
    this.loading = true;
    this.http.get<AnimalResponse>(this.apiUrl).subscribe({
      next: (data) => {
        this.animalData = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading data:', error);
        this.loading = false;
      }
    });
  }

  goBack(): void {
    this.router.navigate(['/dashboard']);
  }
}
