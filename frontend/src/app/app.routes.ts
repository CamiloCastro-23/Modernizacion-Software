import { Routes } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard/dashboard.component';
import { DogComponent } from './dashboard/dogs/dogs.component';
import { CatComponent } from './dashboard/cats/cats.component';
import { FishComponent } from './dashboard/fish/fish.component';
import { BirdComponent } from './dashboard/birds/birds.component';
import { ReptilesComponent } from './dashboard/reptiles/reptiles.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'dogs', component: DogComponent },
  { path: 'cats', component: CatComponent },
  { path: 'fish', component: FishComponent },
  { path: 'birds', component: BirdComponent },
  { path: 'reptiles', component: ReptilesComponent },
  { path: '**', redirectTo: '/dashboard' }
];
