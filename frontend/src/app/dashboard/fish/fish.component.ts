import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';

interface Product {
  product_id: string;
  name: string;
  category: string;
}

interface FishResponse {
  category: string;
  count: number;
  products: Product[];
}

@Component({
  selector: 'app-fish',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './fish.component.html',
  styleUrls: []
})
export class FishComponent implements OnInit {

  fishData: FishResponse | null = null;
  loading = true;

  private apiUrl = 'https://f8avd3hxyl.execute-api.us-east-1.amazonaws.com/dev/shop/fish';

  constructor(
    private router: Router,
    private http: HttpClient
  ) {
    console.log('🐠 FishComponent constructor called');
  }

  ngOnInit(): void {
    console.log('🚀 FishComponent ngOnInit called');
    this.loadFishData();
  }

  loadFishData(): void {
    console.log('📡 Starting API call to:', this.apiUrl);
    this.loading = true;

    this.http.get<FishResponse>(this.apiUrl).subscribe({
      next: (data) => {
        console.log('✅ Fish data loaded successfully:', data);
        this.fishData = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('❌ Error loading fish data:', error);
        console.error('Error details:', error.message);
        console.error('Status:', error.status);
        this.loading = false;
      }
    });
  }

  goBack(): void {
    console.log('🔙 Navigating back to dashboard');
    this.router.navigate(['/dashboard']);
  }

}
